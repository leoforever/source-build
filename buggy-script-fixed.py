#!/usr/bin/env python3
"""
文件处理脚本

功能：处理目录中的所有文件，统计行数和大小
用法：python3 buggy-script.py [目录] [--output 输出文件]

示例:
    python3 buggy-script.py /tmp
    python3 buggy-script.py /home/user/docs --output report.txt
"""

import os
import sys
import argparse
from pathlib import Path
from typing import List, Dict


def process_files(directory: str, output_file: str = None) -> List[Dict]:
    """
    处理目录中的所有文件
    
    Args:
        directory: 要处理的目录路径
        output_file: 输出文件路径（可选，默认为 /tmp/output.txt）
    
    Returns:
        包含文件信息的列表，每个元素包含 file, lines, size
    
    Raises:
        FileNotFoundError: 目录不存在
        NotADirectoryError: 路径不是目录
        PermissionError: 没有读取权限
    """
    # 检查目录是否存在
    if not os.path.exists(directory):
        raise FileNotFoundError(f"目录不存在：{directory}")
    
    if not os.path.isdir(directory):
        raise NotADirectoryError(f"路径不是目录：{directory}")
    
    # 检查读取权限
    if not os.access(directory, os.R_OK):
        raise PermissionError(f"没有读取权限：{directory}")
    
    results = []
    
    try:
        files = os.listdir(directory)
    except PermissionError as e:
        print(f"错误：无法读取目录 {directory}: {e}", file=sys.stderr)
        raise
    
    for filename in files:
        filepath = os.path.join(directory, filename)
        
        # 跳过目录，只处理文件
        if os.path.isdir(filepath):
            continue
        
        try:
            # 检查读取权限
            if not os.access(filepath, os.R_OK):
                print(f"警告：跳过无读取权限的文件 {filename}", file=sys.stderr)
                continue
            
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                lines = content.split('\n')
                
                results.append({
                    'file': filename,
                    'lines': len(lines),
                    'size': os.path.getsize(filepath)
                })
        except (IOError, OSError) as e:
            print(f"警告：处理文件 {filename} 时出错：{e}", file=sys.stderr)
            continue
        except UnicodeDecodeError as e:
            print(f"警告：文件 {filename} 编码错误，跳过：{e}", file=sys.stderr)
            continue
    
    # 写入输出文件
    if output_file is None:
        output_file = '/tmp/output.txt'
    
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            for r in results:
                f.write(f"{r['file']}: {r['lines']} lines, {r['size']} bytes\n")
        print(f"结果已保存到：{output_file}")
    except (IOError, OSError) as e:
        print(f"错误：无法写入输出文件 {output_file}: {e}", file=sys.stderr)
        raise
    
    return results


def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description='处理目录中的所有文件，统计行数和大小',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
    python3 buggy-script.py /tmp
    python3 buggy-script.py /home/user/docs --output report.txt
        """
    )
    
    parser.add_argument(
        'directory',
        nargs='?',
        default='/tmp',
        help='要处理的目录路径（默认：/tmp）'
    )
    
    parser.add_argument(
        '--output', '-o',
        dest='output_file',
        default='/tmp/output.txt',
        help='输出文件路径（默认：/tmp/output.txt）'
    )
    
    args = parser.parse_args()
    
    try:
        results = process_files(args.directory, args.output_file)
        print(f"✅ 处理了 {len(results)} 个文件")
        
        # 显示统计信息
        if results:
            total_lines = sum(r['lines'] for r in results)
            total_size = sum(r['size'] for r in results)
            print(f"   总行数：{total_lines:,}")
            print(f"   总大小：{total_size:,} bytes")
            
    except (FileNotFoundError, NotADirectoryError, PermissionError) as e:
        print(f"❌ 错误：{e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ 未知错误：{e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

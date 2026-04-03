#!/usr/bin/env python3
"""
这是一个有 bug 的脚本 - 用于演示 PR Review 功能
"""

import os
import sys

def process_files(directory):
    """处理目录中的所有文件"""
    # BUG 1: 没有检查目录是否存在
    files = os.listdir(directory)
    
    results = []
    for filename in files:
        # BUG 2: 没有过滤，会尝试读取目录
        with open(directory + '/' + filename, 'r') as f:
            content = f.read()
            # BUG 3: 没有异常处理
            lines = content.split('\n')
            results.append({
                'file': filename,
                'lines': len(lines),
                'size': os.path.getsize(directory + '/' + filename)
            })
    
    # BUG 4: 硬编码路径
    output_file = '/tmp/output.txt'
    with open(output_file, 'w') as f:
        for r in results:
            f.write(f"{r['file']}: {r['lines']} lines, {r['size']} bytes\n")
    
    return results

def main():
    # BUG 5: 没有命令行参数处理
    directory = '/tmp'
    results = process_files(directory)
    print(f"处理了 {len(results)} 个文件")

if __name__ == '__main__':
    main()

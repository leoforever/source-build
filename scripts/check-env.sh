#!/bin/bash
# 检查编译环境

echo "=== 编译环境检查 ==="
echo ""
echo "📦 系统信息:"
echo "  架构：$(uname -m)"
echo "  系统：$(uname -s -r)"
echo ""
echo "🐍 Python:"
python3 --version 2>&1 || echo "  未安装"
echo ""
echo "🟢 Node.js:"
node --version 2>&1 || echo "  未安装"
npm --version 2>&1 || echo "  未安装"
echo ""
echo "🔧 编译工具:"
gcc --version 2>&1 | head -1 || echo "  未安装"
make --version 2>&1 | head -1 || echo "  未安装"
echo ""
echo "💾 内存:"
free -h | grep Mem | awk '{print "  总计：" $2 " / 可用：" $4}'
echo ""
echo "💿 磁盘空间:"
df -h / | tail -1 | awk '{print "  总计：" $2 " / 可用：" $4}'

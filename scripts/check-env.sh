#!/bin/bash
# 检查编译环境

echo "=== 编译环境检查 ==="
echo "架构：$(uname -m)"
echo "Python: $(python3 --version 2>&1)"
echo "Node: $(node --version 2>&1)"
echo "GCC: $(gcc --version 2>&1 | head -1)"
echo "内存：$(free -h | grep Mem | awk '{print $2}')"

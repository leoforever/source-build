#!/bin/bash
# 安装 Python 常见依赖

set -e
echo "=== 安装 Python 编译依赖 ==="

DEPS="python3-dev python3-pip libxml2-dev libxslt1-dev libssl-dev"
echo "安装系统包：$DEPS"
sudo apt install -y $DEPS

echo "✅ 完成"

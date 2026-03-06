#!/bin/bash
# 安装 Python 编译依赖

set -e

echo "=== Python 编译依赖安装 ==="
echo ""
echo "选择安装方式:"
echo "  1) 安装常用依赖 (推荐)"
echo "  2) 安装全部依赖 (完整)"
echo "  3) 自定义安装"
echo ""
read -p "请选择 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "📦 安装常用依赖..."
        DEPS="python3-dev python3-pip libxml2-dev libxslt1-dev libssl-dev"
        echo "  包列表：$DEPS"
        sudo apt install -y $DEPS
        ;;
        
    2)
        echo ""
        echo "📦 安装全部依赖..."
        DEPS="python3-dev python3-pip libxml2-dev libxslt1-dev libssl-dev libffi-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libblas-dev liblapack-dev gfortran"
        echo "  包列表：$DEPS"
        sudo apt install -y $DEPS
        ;;
        
    3)
        echo ""
        echo "📦 自定义安装..."
        echo "请输入包名 (空格分隔):"
        read -p "> " DEPS
        if [ -n "$DEPS" ]; then
            sudo apt install -y $DEPS
        else
            echo "❌ 未输入包名"
            exit 1
        fi
        ;;
        
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "✅ 完成"
echo ""
echo "验证安装:"
echo "  python3 --version"
echo "  pip3 --version"

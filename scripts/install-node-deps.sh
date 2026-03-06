#!/bin/bash
# 安装 Node.js 编译依赖
# 支持龙芯架构完整安装或系统包安装

set -e

echo "=== Node.js 编译依赖安装 ==="
echo ""
echo "选择安装方式:"
echo "  1) 龙芯架构完整安装 (推荐，Node.js v22.20.0 loong64)"
echo "  2) 仅安装编译依赖 (系统 Node.js)"
echo ""
read -p "请选择 [1-2]: " choice

case $choice in
    1)
        echo ""
        echo "📦 龙芯架构 Node.js 完整安装..."
        echo ""
        
        # 检查是否已安装
        if [ -d "/home/loongson/node-v22.20.0-linux-loong64" ]; then
            echo "⚠️  Node.js 已安装，跳过下载"
        else
            echo "下载 Node.js v22.20.0 (loong64)..."
            cd ~
            wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz
            echo "解压..."
            tar -xzvf node-v22.20.0-linux-loong64.tar.gz
        fi
        
        echo ""
        echo "配置 PATH..."
        echo "需要 root 权限编辑 /etc/profile"
        echo "请在 /etc/profile 最后一行添加:"
        echo ""
        echo "  export PATH=/home/loongson/node-v22.20.0-linux-loong64/bin:\$PATH"
        echo ""
        echo "然后执行：source /etc/profile"
        echo ""
        
        ;;
        
    2)
        echo ""
        echo "📦 安装编译依赖..."
        DEPS="build-essential python3 make"
        sudo apt install -y $DEPS
        ;;
        
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo ""
echo "验证安装:"
echo "  node --version"
echo "  npm --version"
echo ""
echo "✅ 完成"

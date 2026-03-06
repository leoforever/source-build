#!/bin/bash
# 发布 source-build skill 到 GitHub
# 用法：bash scripts/publish-to-github.sh

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="source-build"

echo "🛠️  发布 source-build 到 GitHub"
echo "📁 目录：$SKILL_DIR"
echo ""

# 检查 gh 是否安装
if ! command -v gh &> /dev/null; then
    echo "❌ gh (GitHub CLI) 未安装"
    echo "请安装：sudo apt install gh"
    exit 1
fi

# 检查是否已登录
echo "🔐 检查 GitHub 登录状态..."
if ! gh auth status &> /dev/null; then
    echo ""
    echo "⚠️  未登录 GitHub，请先登录:"
    echo ""
    echo "  gh auth login"
    echo ""
    echo "或使用 token:"
    echo "  echo 'YOUR_TOKEN' | gh auth login --with-token"
    echo ""
    read -p "是否现在登录？[y/n] " login
    if [ "$login" = "y" ]; then
        gh auth login
    else
        echo "❌ 需要登录才能发布"
        exit 1
    fi
fi
echo "✅ GitHub 登录成功"
echo ""

cd "$SKILL_DIR"

# 检查是否已是 git 仓库
if [ ! -d ".git" ]; then
    echo "📦 初始化 git 仓库..."
    git init
    echo ""
fi

# 创建必要的文件
echo "📝 检查必要文件..."

# .gitignore
if [ ! -f ".gitignore" ]; then
    echo "  创建 .gitignore"
    cat > .gitignore << 'EOF'
# OpenClaw
*.log
compile-*.log

# Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*
EOF
fi

# LICENSE
if [ ! -f "LICENSE" ]; then
    echo "  创建 LICENSE (MIT)"
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 loongson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
fi

# 更新 README.md
if [ ! -f "README.md" ] || [ "$(wc -l < README.md)" -lt 20 ]; then
    echo "  创建 README.md"
    cat > README.md << 'EOF'
# source-build - OpenClaw 源码编译技能

从源码编译安装软件包的辅助技能，支持 Python、Node.js、C/C++、Rust 等。

## ✨ 特性

- 🐍 **Python 编译支持** - PEP 668、cryptography、lxml、numpy 等
- 🟢 **Node.js 编译支持** - node-gyp、npm 配置、native 模块
- 🔧 **C/C++ 编译支持** - CMake、autotools、依赖查找
- 🦀 **Rust 编译支持** - 工具链、镜像配置、cargo
- 🐉 **龙芯架构优化** - loong64 专用安装指南

## 📦 安装

### 方法 1: Git 克隆

```bash
git clone https://github.com/loongson/source-build.git ~/.openclaw/skills/source-build
openclaw gateway restart
```

### 方法 2: 手动下载

1. 下载 ZIP 文件
2. 解压到 `~/.openclaw/skills/source-build/`
3. 重启 OpenClaw

## 🚀 使用

向 OpenClaw agent 询问：

- "帮我编译这个 Python 项目"
- "Node.js 项目编译失败怎么办"
- "龙芯架构如何安装 Node.js"
- "cryptography 编译错误"

## 📚 文档

| 文档 | 内容 |
|------|------|
| [docs/common-deps.md](docs/common-deps.md) | Python/Node/C++/Rust 常见依赖 |
| [docs/troubleshooting.md](docs/troubleshooting.md) | 编译错误排查指南 |
| [docs/python-notes.md](docs/python-notes.md) | Python 编译经验 |
| [docs/node-notes.md](docs/node-notes.md) | Node.js 编译经验 |
| [docs/nodejs-loongarch-install.md](docs/nodejs-loongarch-install.md) | 龙芯 Node.js 安装指南 |

## 🛠️ 脚本

- `scripts/check-env.sh` - 检查编译环境
- `scripts/install-python-deps.sh` - 安装 Python 依赖
- `scripts/install-node-deps.sh` - 安装 Node.js 依赖

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可

MIT License
EOF
fi

echo "✅ 必要文件检查完成"
echo ""

# Git 操作
echo "📦 Git 操作..."
git add .
echo ""

# 检查是否有变更
if git diff --staged --quiet; then
    echo "⚠️  没有需要提交的变更"
else
    read -p "提交信息 [Initial commit]: " commit_msg
    commit_msg="${commit_msg:-Initial commit: source-build skill for OpenClaw}"
    
    git commit -m "$commit_msg"
    echo "✅ 提交成功"
fi
echo ""

# 检查远程仓库
if git remote | grep -q "origin"; then
    echo "⚠️  已存在远程仓库"
    read -p "是否更新远程仓库？[y/n] " update
    if [ "$update" = "y" ]; then
        git push -u origin main 2>/dev/null || git push -u origin master
        echo "✅ 推送成功"
    fi
else
    echo "🌐 创建 GitHub 仓库..."
    echo ""
    echo "选择仓库可见性:"
    echo "  1) 公开仓库 (public)"
    echo "  2) 私有仓库 (private)"
    echo ""
    read -p "请选择 [1-2]: " visibility
    
    if [ "$visibility" = "1" ]; then
        VISIBILITY="--public"
    else
        VISIBILITY="--private"
    fi
    
    # 创建仓库
    gh repo create "$REPO_NAME" $VISIBILITY --source=. --remote=origin --push
    
    echo ""
    echo "✅ 仓库创建成功!"
    echo ""
    echo "🌐 访问仓库:"
    echo "   https://github.com/loongson/$REPO_NAME"
fi

echo ""
echo "🎉 发布完成!"
echo ""
echo "📝 下一步:"
echo "  1. 访问 GitHub 仓库页面"
echo "  2. 添加仓库描述和主题"
echo "  3. 测试安装：git clone <repo-url>"
echo ""

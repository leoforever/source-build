# source-build 发布到 GitHub 指南

## 📦 准备工作

### 1. 登录 GitHub

```bash
# 方法 1: 交互式登录（推荐）
gh auth login

# 方法 2: 使用 token
echo 'YOUR_GITHUB_TOKEN' | gh auth login --with-token
```

**Token 权限要求:**
- ✅ `repo` - 完整仓库权限
- ✅ `workflow` - GitHub Actions（可选）

### 2. 验证登录

```bash
gh auth status
```

应该显示：
```
✓ Logged in to github.com as <your-username>
```

---

## 🚀 发布步骤

### 方法 1: 使用发布脚本（推荐）

```bash
cd /home/loongson/.openclaw/skills/source-build
bash scripts/publish-to-github.sh
```

### 方法 2: 手动发布

```bash
# 1. 初始化 git 仓库
cd /home/loongson/.openclaw/skills/source-build
git init

# 2. 添加所有文件
git add .

# 3. 创建初始提交
git commit -m "Initial commit: source-build skill for OpenClaw"

# 4. 创建 GitHub 仓库
gh repo create source-build --public --source=. --remote=origin --push

# 或手动创建仓库后推送：
# git remote add origin https://github.com/YOUR_USERNAME/source-build.git
# git branch -M main
# git push -u origin main
```

---

## 📁 仓库结构

```
source-build/
├── SKILL.md                  # OpenClaw skill 定义
├── README.md                 # 使用说明
├── _meta.json                # 元数据
├── package.json              # NPM 包信息
├── .gitignore                # Git 忽略文件
├── LICENSE                   # 开源协议
├── docs/                     # 文档目录
│   ├── common-deps.md        # 常见依赖
│   ├── node-notes.md         # Node.js 经验
│   ├── nodejs-loongarch-install.md  # 龙芯 Node 安装
│   ├── python-notes.md       # Python 经验
│   └── troubleshooting.md    # 问题排查
├── scripts/                  # 脚本目录
│   ├── check-env.sh          # 环境检查
│   ├── install-node-deps.sh  # Node 依赖安装
│   └── install-python-deps.sh # Python 依赖安装
├── snippets/                 # 配置片段
│   └── common-configs.md
└── examples/                 # 示例
    └── compile-scripts.sh
```

---

## 📝 README.md 模板

创建 `README.md` 包含：

```markdown
# source-build - OpenClaw 源码编译技能

从源码编译安装软件包的辅助技能，支持 Python、Node.js、C/C++、Rust 等。

## 特性

- 🐍 Python 编译支持（PEP 668、cryptography、lxml 等）
- 🟢 Node.js 编译支持（node-gyp、npm 配置等）
- 🔧 C/C++ 编译支持（CMake、autotools 等）
- 🦀 Rust 编译支持（镜像配置、cargo 等）
- 🐉 龙芯架构优化（loong64 专用指南）

## 安装

### OpenClaw

```bash
# 克隆到全局 skills 目录
git clone https://github.com/YOUR_USERNAME/source-build.git ~/.openclaw/skills/source-build

# 重启 OpenClaw
openclaw gateway restart
```

### 或使用 ClawHub

```bash
clawhub install source-build
```

## 使用

向 OpenClaw agent 询问：
- "帮我编译这个 Python 项目"
- "Node.js 项目编译失败怎么办"
- "龙芯架构如何安装 Node.js"

## 文档

- [常见依赖](docs/common-deps.md)
- [问题排查](docs/troubleshooting.md)
- [Python 经验](docs/python-notes.md)
- [Node.js 经验](docs/node-notes.md)
- [龙芯 Node 安装](docs/nodejs-loongarch-install.md)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可

MIT License
```

---

## 🔧 .gitignore 模板

创建 `.gitignore`：

```
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
```

---

## 📄 LICENSE 模板

使用 MIT License：

```markdown
MIT License

Copyright (c) 2026 YOUR_NAME

Permission is hereby granted...
```

---

## ✅ 发布后验证

### 1. 检查仓库

```bash
# 访问 GitHub 仓库页面
gh repo view source-build --web
```

### 2. 测试安装

```bash
# 克隆测试
cd /tmp
git clone https://github.com/YOUR_USERNAME/source-build.git
cd source-build
ls -la
```

### 3. 更新 ClawHub（可选）

如果发布到 ClawHub：

```bash
# 同步到 ClawHub
clawhub sync --all
```

---

## 🔄 后续更新

```bash
cd /home/loongson/.openclaw/skills/source-build

# 修改文件后
git add .
git commit -m "描述修改内容"
git push
```

---

## 📊 GitHub Actions（可选）

创建 `.github/workflows/test.yml` 自动测试：

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate SKILL.md
        run: |
          head -5 SKILL.md | grep -q "^---$"
          grep -q "^name:" SKILL.md
          grep -q "^description:" SKILL.md
```

---

## 🎯 快速命令总结

```bash
# 登录
gh auth login

# 创建并发布
cd /home/loongson/.openclaw/skills/source-build
git init
git add .
git commit -m "Initial commit"
gh repo create source-build --public --push

# 更新
git add .
git commit -m "Update"
git push
```

---

## 📚 参考

- [GitHub CLI](https://cli.github.com/)
- [OpenClaw Skills](https://docs.openclaw.ai/tools/skills)
- [ClawHub](https://clawhub.com)

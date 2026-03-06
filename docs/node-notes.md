# Node.js 编译经验笔记

## 📦 龙芯架构安装

**快速安装指南:** 查看 [`nodejs-loongarch-install.md`](nodejs-loongarch-install.md)

**一键安装脚本:**
```bash
~/.openclaw/skills/source-build/scripts/install-node-deps.sh
# 选择 1) 龙芯架构完整安装
```

---

## 标准编译流程

```bash
# 1. 检查项目
ls package.json package-lock.json

# 2. 查看 Node 版本要求
cat package.json | grep -A5 '"engines"'

# 3. 检查当前版本
node --version
npm --version

# 4. 安装依赖
npm install

# 5. 全局安装（如果是 CLI 工具）
npm install -g .

# 6. 验证
xxx --version
```

---

## 常见问题

### 1. node-gyp 编译失败

**错误:**
```
gyp ERR! find Python
gyp ERR! stack Error: Can't find Python executable "python"
```

**解决:**
```bash
sudo apt install python3 make g++
npm config set python python3
```

---

### 2. npm install 卡住

**原因:** 网络问题或包太大

**解决:**
```bash
# 检查网络连接
ping registry.npmjs.org

# 清理缓存重试
npm cache clean --force
npm install
```

---

### 3. node-sass 编译失败

**解决:**
```bash
# 方案 1: 使用 dart-sass（推荐）
npm uninstall node-sass
npm install sass

# 方案 2: 跳过编译
npm install node-sass --ignore-scripts
```

---

### 4. canvas 编译失败

**错误:** 缺少图形库

**解决:**
```bash
sudo apt install libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
npm install canvas
```

---

### 5. bcrypt 编译失败

**解决:**
```bash
sudo apt install build-essential
npm install bcrypt
```

---



---

## 版本管理

### 使用 nvm 管理 Node 版本
```bash
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 安装特定版本
nvm install 18
nvm use 18

# 设置默认
nvm alias default 18
```

### 检查项目要求的版本
```bash
cat package.json | grep -A3 '"engines"'
```

---

## 调试技巧

### 查看详细安装过程
```bash
npm install --verbose 2>&1 | tee install.log
```

### 查看已安装包
```bash
npm list
npm list -g --depth=0  # 全局包
```

### 检查过时的包
```bash
npm outdated
```

### 清理缓存
```bash
npm cache clean --force
npm cache verify
```

---

## 龙芯架构注意事项

1. **node-gyp**: 确保安装了 `python3 make g++`
2. **预编译包**: 某些 native 模块可能没有 loong64 预编译
3. **版本兼容**: 使用较新的 Node.js 版本（18+）兼容性更好

---

## 实用命令

### 全局安装 CLI 工具
```bash
npm install -g <package>
```

### 本地安装项目依赖
```bash
npm install
```

### 安装开发依赖
```bash
npm install --save-dev <package>
```

### 查看包信息
```bash
npm info <package>
```

### 快速创建项目
```bash
npm init -y  # 快速创建 package.json
```

---

## 常见问题速查

| 问题 | 解决方案 |
|------|----------|
| EACCES 权限错误 | `npm config set prefix ~/.npm-global` |
| ENOSPC 空间不足 | 清理磁盘或增加空间 |
| ETIMEDOUT 超时 | 换镜像源或检查网络 |
| node-gyp 失败 | 安装 `python3 make g++` |
| 包版本冲突 | `npm install --legacy-peer-deps` |

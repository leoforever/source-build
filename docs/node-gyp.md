# node-gyp 编译问题

> Node.js native 模块编译问题

---

## 问题症状

```
gyp ERR! find Python
gyp ERR! stack Error: Can't find Python executable "python"
```

---

## 解决方案

### 1. 安装编译依赖

```bash
sudo apt install build-essential python3 make g++
npm config set python python3
```

### 2. 龙芯 Node.js 安装

**官方不提供 loong64 预编译，使用非官方构建:**

```bash
# 下载
wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz

# 解压
tar -xzf node-v22.20.0-linux-loong64.tar.gz

# 配置 PATH
export PATH=$PWD/node-v22.20.0-linux-loong64/bin:$PATH

# 验证
node --version  # v22.20.0
```

---

## 常见包问题

| 包 | 问题 | 解决方案 |
|---|------|---------|
| **node-sass** | 不支持 loong64 | `npm install sass` (dart-sass) |
| **canvas** | 缺少图形库 | `apt install libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev` |
| **bcrypt** | 需要编译 | `apt install build-essential` |
| **其他 native** | 缺少依赖 | `apt-file search xxx.h` 查找 |

---

## npm 问题

### 卡住/超时
```bash
# 清理缓存
npm cache clean --force
npm install

# 跳过可选依赖
npm install --no-optional

# 忽略脚本
npm install --ignore-scripts
```

### 镜像配置

**龙芯官方 npm 镜像源：**

```bash
npm config set registry https://registry.loongnix.cn:5873
```

**验证配置：**
```bash
npm config get registry
# 应输出：https://registry.loongnix.cn:5873
```

---

## 权限问题

```bash
# EACCES 错误
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

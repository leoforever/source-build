# 龙芯 Docker 镜像源配置

**龙芯 LoongArch Docker 容器编译环境配置，优先使用龙芯官方镜像源。**

---

## 🐳 镜像源配置

### 主镜像源：lcr.loongnix.cn

```bash
# 龙芯容器 registry
lcr.loongnix.cn
```

### 常用镜像

| 镜像 | 标签 | 用途 |
|------|------|------|
| `lcr.loongnix.cn/loongnix/loongnix-server` | `23.1-beta2` | 龙芯服务器版基础镜像 |
| `lcr.loongnix.cn/loongnix` | `23.1` | 龙芯桌面版基础镜像 |
| `lcr.loongnix.cn/ubuntu` | `22.04-loong64` | Ubuntu LoongArch 版 |

---

## 🔧 使用方式

### 拉取镜像

```bash
docker pull lcr.loongnix.cn/loongnix/loongnix-server:23.1-beta2
```

### 创建编译容器

**⚠️ 注意：不要映射宿主机工作目录，避免影响本地环境！**

```bash
# ❌ 错误：会覆盖宿主机文件
docker run -it --name openclaw-build \
  -v /root/.openclaw/workspace:/workspace \
  lcr.loongnix.cn/loongnix/loongnix-server:23.1-beta2 \
  bash

# ✅ 正确：容器内独立环境
docker run -it --name openclaw-build \
  lcr.loongnix.cn/loongnix/loongnix-server:23.1-beta2 \
  bash
```

**如果需要在宿主机访问构建产物：**
```bash
# 使用 docker cp 复制出来，而不是挂载
docker cp openclaw-build:/workspace/openclaw/dist /tmp/openclaw-dist
```

---

## 📋 编译环境配置（重要！）

### 1. Node.js 安装

**⚠️ 龙芯平台 dnf 源的 Node.js 版本可能过低（只有 v18），推荐使用 unofficial-builds：**

```bash
# 方法 1：使用 unofficial-builds（推荐）
cd /opt
wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz
tar -xzf node-v22.20.0-linux-loong64.tar.gz
export PATH=/opt/node-v22.20.0-linux-loong64/bin:$PATH

# 验证
node --version  # 应为 v22.20.0
npm --version

# 安装 pnpm
npm install -g pnpm
```

**方法 2：使用 dnf（版本可能较旧）**
```bash
dnf install -y nodejs npm
```

### 2. 其他依赖

```bash
# Git
dnf install -y git

# Python
dnf install -y python3

# 编译器
dnf install -y gcc gcc-c++ make

# 工具
dnf install -y curl wget
```

### 3. 环境检查

```bash
# 检查架构
uname -m  # 应为 loongarch64

# 检查 Node.js
node --version  # 建议 v22+

# 检查 pnpm
pnpm --version

# 检查 Git
git --version
```

---

## ⚠️ 常见问题

### GPG 密钥错误

**注意：** loongnix-server 23.1-beta2 镜像通常已预配置软件源和 GPG 密钥，不需要手动导入。

如果遇到 GPG 验证错误，再尝试：

```bash
# 检查现有配置
cat /etc/yum.repos.d/*.repo

# 仅在确实需要时导入
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-loongnix
dnf clean all
dnf makecache
```

---

## 🎯 编译流程示例

```bash
# 1. 创建容器
docker run -it --name openclaw-build \
  -v /root/.openclaw/workspace:/workspace \
  lcr.loongnix.cn/loongnix/loongnix-server:23.1-beta2 \
  bash

# 2. 安装 Node.js 22+（重要！）
cd /opt
wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz
tar -xzf node-v22.20.0-linux-loong64.tar.gz
export PATH=/opt/node-v22.20.0-linux-loong64/bin:$PATH

# 3. 安装其他依赖
dnf install -y git python3 gcc gcc-c++ make

# 配置 npm 镜像源（龙芯官方源）
npm config set registry https://registry.loongnix.cn:5873

npm install -g pnpm

# 4. 克隆源码
cd /workspace
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 5. 编译
LOGFILE="/tmp/openclaw-build-$(date +%Y%m%d-%H%M%S).log"
pnpm install 2>&1 | tee -a $LOGFILE
pnpm build 2>&1 | tee -a $LOGFILE
```

---

## 📝 注意事项

1. **Node.js 版本** - 必须 v22+，使用 unofficial-builds 安装
2. **日志记录** - 所有编译过程记录到日志文件
3. **容器清理** - 编译完成后及时清理

---

## 🔗 相关文档

- [pip-sources.md](pip-sources.md) - pip 源配置
- [node-gyp.md](node-gyp.md) - Node 原生模块编译
- [../SKILL.md](../SKILL.md) - 主技能文档

# 常见依赖安装

## Python 编译依赖

### 基础开发包
```bash
sudo apt install python3-dev python3-pip python3-venv
```

### 常用编译依赖
```bash
# lxml (XML 处理)
sudo apt install libxml2-dev libxslt1-dev python3-lxml

# cryptography (加密)
sudo apt install python3-cryptography libssl-dev

# numpy/scipy (科学计算)
sudo apt install libblas-dev liblapack-dev libatlas-base-dev gfortran

# Pillow (图像处理)
sudo apt install libjpeg-dev zlib1g-dev libtiff-dev libfreetype6-dev liblcms2-dev

# mysqlclient
sudo apt install default-libmysqlclient-dev

# psycopg2 (PostgreSQL)
sudo apt install libpq-dev

# python-dev-tools
sudo apt install python3-dev
```

### 龙芯架构特殊依赖
```bash
# loongarch64 可能需要从 loongnix 仓库安装
# 检查 loongnix 源是否配置
cat /etc/apt/sources.list | grep loongnix
```

---

## Node.js 编译依赖

### 龙芯架构安装（推荐）

**快速安装指南:** 查看 [`nodejs-loongarch-install.md`](nodejs-loongarch-install.md)

**一键安装脚本:**
```bash
~/.openclaw/skills/source-build/scripts/install-node-deps.sh
# 选择 1) 龙芯架构完整安装
```

**手动安装步骤:** 见 [`nodejs-loongarch-install.md`](nodejs-loongarch-install.md)

### 系统包安装（备选）

```bash
sudo apt install nodejs npm
```

### node-gyp 编译需要
```bash
sudo apt install build-essential python3
```

### 常见问题
```bash
# node-sass / sass 编译失败
npm install sass --ignore-scripts

# canvas 编译需要
sudo apt install libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# bcrypt 编译需要
sudo apt install build-essential
```



---

## C/C++ 编译依赖

### 基础编译工具链
```bash
sudo apt install build-essential cmake make autoconf automake libtool pkg-config
```

### 常用库
```bash
# SSL/TLS
sudo apt install libssl-dev

# Zlib 压缩
sudo apt install zlib1g-dev

# CURL
sudo apt install libcurl4-openssl-dev

# SQLite
sudo apt install libsqlite3-dev

# Protocol Buffers
sudo apt install protobuf-compiler libprotobuf-dev

# Boost
sudo apt install libboost-all-dev
```

---

## Rust 编译依赖

### Rust 工具链
```bash
# 官方安装（需要网络访问 static.rust-lang.org）
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 或系统包
sudo apt install rustc cargo
```

### 常见问题
- **DNS 解析失败**：检查网络，或配置镜像源
- **编译慢**：使用 `sccache` 缓存

---

## Go 编译依赖

```bash
sudo apt install golang-go
```

---

## 通用技巧

### 1. 查找缺少的头文件
```bash
# 错误：xxx.h: No such file or directory
# 使用 apt-file 搜索
sudo apt install apt-file
apt-file update
apt-file search xxx.h
```

### 2. 查找缺少的库
```bash
# 错误：cannot find -lxxx
# 搜索库文件
apt-file search libxxx.so
```

### 3. 查看包包含的文件
```bash
dpkg -L package-name
```

### 4. 检查已安装的库
```bash
ldconfig -p | grep xxx
```

---

## 龙芯架构注意事项

1. **Rust 编译**：`static.rust-lang.org` 可能 DNS 解析失败，建议使用系统包
2. **预编译包**：优先使用 `apt` 安装预编译的 Python/Node 包
3. **架构特定**：某些包可能没有 loong64 预编译，需要从源码编译

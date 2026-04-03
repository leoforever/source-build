# 基础设施统一配置

> 镜像源和工具链配置

---

## apt 源（loongnix）

```bash
# /etc/apt/sources.list
deb https://mirrors.loongnix.cn/loongnix repo main
deb https://pkg.loongnix.cn/loongnix/25/ loongnix-stable main contrib non-free
```

---

## Python 源

```bash
# 永久配置
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF

# 或 loongnix 源
# index-url = https://lpypi.loongnix.cn/loongson/pypi
```

---

## npm 源

```bash
# 全局配置
npm config set registry https://registry.npmmirror.com

# 或 loongnix 源
# npm config set registry https://registry.loongnix.cn:5873 --global
```

---

## Rust 源

```bash
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
```

---

## 交叉编译工具链

```bash
# GCC
sudo apt install gcc-loongarch64-linux-gnu g++-loongarch64-linux-gnu

# 验证
loongarch64-linux-gnu-gcc --version
```

---

## Docker 镜像

```bash
# LoongArch 基础镜像
docker pull ghcr.io/loongson-cloud-community/loongnix-alpine:3.19

# Node.js
docker pull ghcr.io/loongson-cloud-community/nodejs:20-alpine

# Python manylinux
docker pull ghcr.io/loong64/manylinux_2_38_loongarch64:latest

# onnxruntime 构建
docker pull ghcr.io/loong64/onnxruntimecpubuildpythonloongarch64:latest
```

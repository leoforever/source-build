# Python wheel 缺失解决方案

> PyPI 上没有 loong64 预编译 wheel 时的处理方案

---

## 问题症状

```
ERROR: No matching distribution found for package (loong64)
```

---

## 解决方案优先级

### 1️⃣ 优先：系统包

```bash
sudo apt install python3-xxx
```

**适用包:**
| 包 | 系统包 |
|---|---|
| cryptography | python3-cryptography |
| lxml | python3-lxml |
| numpy | python3-numpy |
| scipy | python3-scipy |
| Pillow | python3-pil |

---

### 2️⃣ 次选：从源码编译

```bash
pip install --no-binary :all: package
```

**前提条件:**
```bash
sudo apt install build-essential python3-dev
```

---

### 3️⃣ 特定包处理

#### cryptography
```bash
# 需要 Rust，优先系统包
sudo apt install python3-cryptography

# 或安装系统 Rust
sudo apt install rustc cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true
pip install cryptography
```

#### lxml
```bash
# 安装依赖
sudo apt install libxml2-dev libxslt1-dev

# 或直接用系统包
sudo apt install python3-lxml
```

#### numpy/scipy
```bash
# 编译时间长，优先系统包
sudo apt install python3-numpy python3-scipy

# 或安装依赖后编译
sudo apt install libblas-dev liblapack-dev gfortran
```

#### Pillow
```bash
sudo apt install libjpeg-dev zlib1g-dev libfreetype6-dev
pip install Pillow
```

---

### 4️⃣ 使用镜像源

```bash
# loongnix 源
pip install -i https://mirrors.loongnix.cn/pypi/web/simple package

# 清华源
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple package
```

---

## PEP 668 处理（Python 3.12+）

**错误:**
```
× This environment is externally managed
```

**方案:**
```bash
# 推荐：虚拟环境
python3 -m venv venv
source venv/bin/activate
pip install package

# 或（仅测试环境）
pip install --break-system-packages package
```

---

## Free-threaded Python (3.13t/3.14t)

```bash
PYTHON_VERSION="cp313t"
if [[ "$PYTHON_VERSION" == *t ]]; then
    PYTHON_PATH="${PYTHON_VERSION%t}"  # 移除 t 后缀
fi
```

---

## 构建缓存优化

```bash
# 创建缓存目录
mkdir -p "${HOME}/data/build"

# Docker 挂载
docker run --volume "${HOME}/data/build:/build" build-image
```

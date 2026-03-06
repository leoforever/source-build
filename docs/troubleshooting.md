# 常见问题排查

## Python 编译问题

### 1. externally-managed-environment (PEP 668)

**错误信息:**
```
× This environment is externally managed
╰─> To install Python packages system-wide, try apt install python3-xyz
```

**解决方案:**

方案 A - 使用虚拟环境（推荐）:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -e .
```

方案 B - 使用 --break-system-packages:
```bash
pip install --break-system-packages -e .
```

方案 C - 使用系统包:
```bash
sudo apt install python3-xxx
```

---

### 2. Rust 编译失败（cryptography 等包）

**错误信息:**
```
error: failed to download file error=Reqwest(reqwest::Error { 
  kind: Request, url: "https://static.rust-lang.org/..."
  source: ... dns error ...
})
```

**原因:** 无法访问 Rust 官方源

**解决方案:**

方案 A - 使用系统 Rust:
```bash
sudo apt install rustc cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true
pip install --break-system-packages cryptography
```

方案 B - 配置 Rust 镜像:
```bash
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
curl --proto '=https' --tlsv1.2 -sSf https://mirrors.ustc.edu.cn/rust-static/rustup/rustup-init.sh | sh
```

方案 C - 使用预编译包:
```bash
sudo apt install python3-cryptography
```

---

### 3. lxml 编译失败

**错误信息:**
```
Error: Please make sure the libxml2 and libxslt development packages are installed.
```

**解决方案:**
```bash
sudo apt install libxml2-dev libxslt1-dev python3-lxml
```

---

### 4. numpy 编译失败

**错误信息:**
```
numpy requires BLAS/LAPACK
```

**解决方案:**
```bash
sudo apt install libblas-dev liblapack-dev libatlas-base-dev gfortran
# 或直接使用预编译包
sudo apt install python3-numpy
```

---

### 5. 找不到 Python.h

**错误信息:**
```
fatal error: Python.h: No such file or directory
```

**解决方案:**
```bash
sudo apt install python3-dev
```

---

## Node.js 编译问题

### 1. node-gyp 失败

**错误信息:**
```
gyp ERR! find Python
gyp ERR! stack Error: Can't find Python executable "python"
```

**解决方案:**
```bash
sudo apt install python3 make g++
npm config set python python3
```

---

### 2. npm install 卡在某个包

**原因:** 网络问题或包本身编译慢

**解决方案:**
```bash
# 检查网络连接
ping registry.npmjs.org

# 跳过可选依赖
npm install --no-optional

# 忽略脚本（某些包需要预编译）
npm install --ignore-scripts
```

---

### 3. node-sass / sass 编译失败

**解决方案:**
```bash
# 使用 dart-sass 替代
npm uninstall node-sass
npm install sass

# 或跳过编译
npm install node-sass --ignore-scripts
```

---

## C/C++ 编译问题

### 1. configure: error: xxx not found

**解决方案:**
```bash
# 使用 apt-file 查找
sudo apt install apt-file
apt-file update
apt-file search xxx.h

# 安装对应开发包
sudo apt install xxx-dev
```

---

### 2. undefined reference to xxx

**原因:** 链接时找不到库

**解决方案:**
```bash
# 检查库是否安装
ldconfig -p | grep xxx

# 安装库
sudo apt install libxxx-dev

# 指定库路径
./configure LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include"
```

---

### 3. CMake 找不到依赖

**错误信息:**
```
CMake Error at CMakeLists.txt:xx (find_package):
  Could not find a package configuration file provided by "xxx"
```

**解决方案:**
```bash
# 查找 CMake 配置文件
apt-file search xxxConfig.cmake

# 安装对应包
sudo apt install libxxx-dev
```

---

## 通用排查技巧

### 1. 查看详细错误
```bash
# 始终使用 tee 记录日志
make 2>&1 | tee build.log

# 查看最后 100 行
tail -100 build.log
```

### 2. 清理后重新编译
```bash
make clean
# 或
rm -rf build/
./configure --clean
```

### 3. 检查系统架构
```bash
uname -m
# loongarch64 = 龙芯
```

### 4. 检查可用内存
```bash
free -h
# 编译可能需要大量内存
```

### 5. 使用并行编译加速
```bash
make -j$(nproc)
```

---

## 龙芯架构特有坑

1. **Rust 下载失败**: static.rust-lang.org DNS 解析问题，用 apt 安装
2. **预编译包少**: 很多 Python wheel 没有 loong64 版本，需要源码编译
3. **性能问题**: 某些优化可能针对 x86，loong64 可能需要调整编译选项

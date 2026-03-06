# 编译脚本示例

## Python 项目编译脚本

### compile-python.sh
```bash
#!/bin/bash
# Python 源码编译脚本

set -e

PROJECT_DIR="${1:-.}"
LOG_FILE="compile-$(date +%Y%m%d-%H%M%S).log"

echo "=== Python 源码编译 ===" | tee "$LOG_FILE"
echo "项目目录：$PROJECT_DIR" | tee -a "$LOG_FILE"
echo "日志文件：$LOG_FILE" | tee -a "$LOG_FILE"

cd "$PROJECT_DIR"

# 1. 检查项目结构
echo -e "\n[1/5] 检查项目结构..." | tee -a "$LOG_FILE"
if [ -f "pyproject.toml" ]; then
    echo "发现 pyproject.toml" | tee -a "$LOG_FILE"
elif [ -f "setup.py" ]; then
    echo "发现 setup.py" | tee -a "$LOG_FILE"
elif [ -f "setup.cfg" ]; then
    echo "发现 setup.cfg" | tee -a "$LOG_FILE"
else
    echo "❌ 未找到 Python 项目文件" | tee -a "$LOG_FILE"
    exit 1
fi

# 2. 检查依赖文件
echo -e "\n[2/5] 检查依赖..." | tee -a "$LOG_FILE"
if [ -f "requirements.txt" ]; then
    echo "发现 requirements.txt" | tee -a "$LOG_FILE"
fi

# 3. 安装系统依赖（可选）
echo -e "\n[3/5] 安装系统依赖..." | tee -a "$LOG_FILE"
sudo apt install -y python3-dev python3-pip 2>&1 | tee -a "$LOG_FILE"

# 4. 创建虚拟环境
echo -e "\n[4/5] 创建虚拟环境..." | tee -a "$LOG_FILE"
python3 -m venv venv
source venv/bin/activate

# 5. 安装依赖
echo -e "\n[5/5] 安装依赖并编译..." | tee -a "$LOG_FILE"
pip install --upgrade pip 2>&1 | tee -a "$LOG_FILE"
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt 2>&1 | tee -a "$LOG_FILE"
fi
pip install -e . 2>&1 | tee -a "$LOG_FILE"

echo -e "\n✅ 编译完成!" | tee -a "$LOG_FILE"
echo "激活虚拟环境：source venv/bin/activate" | tee -a "$LOG_FILE"
```

---

## Node.js 项目编译脚本

### compile-node.sh
```bash
#!/bin/bash
# Node.js 源码编译脚本

set -e

PROJECT_DIR="${1:-.}"
LOG_FILE="compile-$(date +%Y%m%d-%H%M%S).log"

echo "=== Node.js 源码编译 ===" | tee "$LOG_FILE"
echo "项目目录：$PROJECT_DIR" | tee -a "$LOG_FILE"

cd "$PROJECT_DIR"

# 1. 检查 package.json
echo -e "\n[1/4] 检查项目..." | tee -a "$LOG_FILE"
if [ ! -f "package.json" ]; then
    echo "❌ 未找到 package.json" | tee -a "$LOG_FILE"
    exit 1
fi
echo "发现 package.json" | tee -a "$LOG_FILE"

# 2. 检查 Node 版本
echo -e "\n[2/4] 检查 Node 环境..." | tee -a "$LOG_FILE"
node --version | tee -a "$LOG_FILE"
npm --version | tee -a "$LOG_FILE"

# 3. 安装依赖
echo -e "\n[3/4] 安装依赖..." | tee -a "$LOG_FILE"
npm install 2>&1 | tee -a "$LOG_FILE"

# 5. 全局安装（如果是 CLI）
if grep -q '"bin"' package.json; then
    echo -e "\n检测到 CLI 工具，全局安装..." | tee -a "$LOG_FILE"
    npm install -g . 2>&1 | tee -a "$LOG_FILE"
fi

echo -e "\n✅ 编译完成!" | tee -a "$LOG_FILE"
```

---

## C/C++ 项目编译脚本

### compile-cmake.sh
```bash
#!/bin/bash
# CMake 项目编译脚本

set -e

PROJECT_DIR="${1:-.}"
BUILD_DIR="build"
LOG_FILE="compile-$(date +%Y%m%d-%H%M%S).log"

echo "=== CMake 源码编译 ===" | tee "$LOG_FILE"
echo "项目目录：$PROJECT_DIR" | tee -a "$LOG_FILE"

cd "$PROJECT_DIR"

# 1. 检查 CMakeLists.txt
echo -e "\n[1/5] 检查项目..." | tee -a "$LOG_FILE"
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ 未找到 CMakeLists.txt" | tee -a "$LOG_FILE"
    exit 1
fi

# 2. 安装依赖
echo -e "\n[2/5] 安装编译依赖..." | tee -a "$LOG_FILE"
sudo apt install -y build-essential cmake 2>&1 | tee -a "$LOG_FILE"

# 3. 创建构建目录
echo -e "\n[3/5] 创建构建目录..." | tee -a "$LOG_FILE"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 4. 配置
echo -e "\n[4/5] 运行 CMake..." | tee -a "$LOG_FILE"
cmake .. 2>&1 | tee -a "$LOG_FILE"

# 5. 编译
echo -e "\n[5/5] 编译..." | tee -a "$LOG_FILE"
make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"

# 6. 安装（可选）
echo -e "\n是否安装到系统？(y/n)"
read -r answer
if [ "$answer" = "y" ]; then
    sudo make install 2>&1 | tee -a "$LOG_FILE"
fi

echo -e "\n✅ 编译完成!" | tee -a "$LOG_FILE"
echo "可执行文件在：$BUILD_DIR/" | tee -a "$LOG_FILE"
```

---

## 通用编译检查脚本

### check-deps.sh
```bash
#!/bin/bash
# 检查编译环境

echo "=== 编译环境检查 ==="

echo -e "\n📦 系统信息:"
uname -a
echo "架构：$(uname -m)"

echo -e "\n🐍 Python:"
python3 --version 2>/dev/null || echo "未安装"
pip3 --version 2>/dev/null || echo "未安装"

echo -e "\n🟢 Node.js:"
node --version 2>/dev/null || echo "未安装"
npm --version 2>/dev/null || echo "未安装"

echo -e "\n🔧 编译工具:"
gcc --version 2>/dev/null | head -1 || echo "未安装"
g++ --version 2>/dev/null | head -1 || echo "未安装"
cmake --version 2>/dev/null | head -1 || echo "未安装"
make --version 2>/dev/null | head -1 || echo "未安装"

echo -e "\n🦀 Rust:"
rustc --version 2>/dev/null || echo "未安装"
cargo --version 2>/dev/null || echo "未安装"

echo -e "\n💾 内存:"
free -h | grep Mem

echo -e "\n💿 磁盘空间:"
df -h / | tail -1
```

---

## 使用方法

```bash
# 赋予执行权限
chmod +x *.sh

# 运行检查
./check-deps.sh

# 编译 Python 项目
./compile-python.sh /path/to/project

# 编译 Node 项目
./compile-node.sh /path/to/project

# 编译 CMake 项目
./compile-cmake.sh /path/to/project
```

---
name: source-build
description: 从源码编译安装软件包的辅助技能，支持 Python、Node.js、C/C++、Rust 等，包含常见问题解决方案、依赖安装、错误诊断和经验记录
---

# Source Build - 源码编译专家

**Capability Summary:** 从源码编译安装软件包的辅助技能，支持 Python、Node.js、C/C++、Rust 等语言，包含常见问题解决方案、依赖安装、错误诊断和经验记录。

你是源码编译专家。使用这个技能帮助用户从源码编译安装软件包。

## 🎯 快速开始

"当用户需要编译源码时，按以下流程处理："

### 决策树

- **"帮我编译这个 Python 项目"** → 检查 `docs/python-notes.md`
  - 有 `setup.py` / `pyproject.toml` → Python 项目
  - PEP 668 错误 → 虚拟环境或 `--break-system-packages`
  - cryptography/lxml 失败 → 先装系统依赖

- **"Node.js 项目编译失败"** → 检查 `docs/node-notes.md`
  - node-gyp 错误 → 安装 `python3 make g++`
  - npm 超时 → 检查网络连接
  - node-sass 失败 → 用 dart-sass 替代

- **"龙芯 Node.js 安装"** → 检查 `docs/common-deps.md`
  - 下载 loong64 非官方构建
  - 配置全局 PATH 到 `/etc/profile`
  - 验证安装 `node --version`

- **"C/C++ 项目怎么编译"** → 检查 `docs/common-deps.md`
  - 有 `CMakeLists.txt` → CMake 流程
  - 有 `configure` → autotools 流程
  - 缺头文件 → `apt-file search` 查找

- **"Rust 项目编译问题"** → 检查 `docs/troubleshooting.md`
  - 下载失败 → 配置镜像源
  - 编译慢 → 使用 sccache

## 🛠️ 可用脚本

所有脚本在 `./scripts/`:

### 环境检查
```bash
./scripts/check-env.sh # 检查编译环境
```

### 依赖安装
```bash
./scripts/install-python-deps.sh # Python 编译依赖
./scripts/install-node-deps.sh   # Node.js 编译依赖
```

### 编译流程
```bash
# Python
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pip install -e .

# Node.js
npm install
npm install -g .

# C/C++ (CMake)
mkdir build && cd build
cmake .. && make -j$(nproc)

# C/C++ (autotools)
./configure && make && sudo make install
```

## 📚 文档分类

### 🔧 常见依赖 (`docs/common-deps.md`)
Python、Node.js、C/C++、Rust 的系统依赖安装命令

### 🐛 问题排查 (`docs/troubleshooting.md`)
- Python: PEP 668、cryptography、lxml、numpy
- Node.js: node-gyp、npm 超时、native 模块
- C/C++: 缺头文件、链接错误、CMake 配置
- Rust: 下载失败、镜像配置

### 🐍 Python 经验 (`docs/python-notes.md`)
- 虚拟环境配置
- 常见包编译笔记
- 加速编译技巧
- 调试技巧

### 🟢 Node.js 经验 (`docs/node-notes.md`)
- npm 镜像配置
- node-gyp 问题
- 版本管理
- 常见问题速查

### 💡 示例 (`examples/`)
- `compile-scripts.sh` - 编译脚本示例

### 📋 配置片段 (`snippets/common-configs.md`)
现成的配置命令：
- Python 虚拟环境
- Rust 镜像
- CMake 标准流程

## 📋 工作流程

1. **识别项目类型**
   - Python: `ls setup.py pyproject.toml`
   - Node.js: `ls package.json`
   - C/C++: `ls CMakeLists.txt configure`
   - Rust: `ls Cargo.toml`

2. **检查编译环境**
   ```bash
   ./scripts/check-env.sh
   ```

3. **安装系统依赖**
   ```bash
   ./scripts/install-python-deps.sh  # 或 install-node-deps.sh
   ```

4. **执行编译**
   - 参考对应语言的文档
   - 记录编译日志：`command 2>&1 | tee compile.log`

5. **处理错误**
   - 查看 `docs/troubleshooting.md`
   - 根据错误信息查找解决方案

6. **验证安装**
   ```bash
   python -c "import xxx; print(xxx.__version__)"
   xxx --version
   ```

## 💡 提示

- 始终记录编译日志到文件
- 优先使用 `apt` 安装系统依赖
- Python 3.12+ 注意 PEP 668
- Rust 编译优先用系统包
- 编译失败时保留错误信息

## 📝 输出格式

编译完成后输出：
- ✅ 成功 / ❌ 失败
- 📦 安装路径
- ⚠️ 遇到的问题及解决方案
- ✅ 验证命令

## 🎯 示例交互

**用户:** "帮我编译这个 Python 项目"

**你:**
1. 检查项目类型：`ls setup.py pyproject.toml`
2. 安装依赖：`./scripts/install-python-deps.sh`
3. 创建虚拟环境并编译
4. 如果出错，参考 `docs/troubleshooting.md`
5. 验证安装

**用户:** "cryptography 安装失败"

**你:**
1. 识别问题：Rust 编译需要网络
2. 提供方案：`sudo apt install python3-cryptography`
3. 参考：`docs/troubleshooting.md` 的 Rust 部分

**用户:** "npm install 卡住了"

**你:**
1. 识别问题：网络超时
2. 检查网络连接
3. 清理重试：`npm cache clean --force && npm install`

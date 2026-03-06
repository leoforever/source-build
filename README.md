# source-build 技能

从源码编译安装软件包的辅助技能，支持多种编程语言。

## 📁 目录结构

```
source-build/
├── SKILL.md              # 技能主文件（行为定义）
├── README.md             # 本文件
├── docs/
│   ├── common-deps.md    # 常见依赖安装
│   ├── troubleshooting.md # 常见问题排查
│   ├── python-notes.md   # Python 编译经验
│   └── node-notes.md     # Node.js 编译经验
├── examples/
│   └── compile-scripts.sh # 编译脚本示例
└── scripts/              # 实用脚本（待添加）
```

## 🚀 快速开始

### Python 项目
```bash
# 1. 检查依赖
./check-deps.sh

# 2. 编译
cd /path/to/project
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -e .
```

### Node.js 项目
```bash
cd /path/to/project
npm install
npm install -g .  # 如果是 CLI 工具
```

### C/C++ 项目
```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
```

## 📚 文档索引

| 文档 | 内容 |
|------|------|
| [common-deps.md](docs/common-deps.md) | Python/Node/C++/Rust常见依赖安装命令 |
| [troubleshooting.md](docs/troubleshooting.md) | 编译错误排查指南 |
| [python-notes.md](docs/python-notes.md) | Python 项目编译经验 |
| [node-notes.md](docs/node-notes.md) | Node.js 项目编译经验 |

## 🔧 常用命令

### 检查编译环境
```bash
bash examples/compile-scripts.sh  # 运行检查脚本
```

### 查找缺少的依赖
```bash
# 查找头文件
apt-file search xxx.h

# 查找库文件
apt-file search libxxx.so
```

### 龙芯架构特殊处理
```bash
# 检查架构
uname -m  # loongarch64

# 使用 loongnix 源
cat /etc/apt/sources.list | grep loongnix
```

## ⚠️ 常见坑

1. **Python PEP 668**: 使用虚拟环境或 `--break-system-packages`
2. **Rust 下载失败**: 使用 `apt install rustc cargo`
3. **lxml 编译**: 先装 `libxml2-dev libxslt1-dev`
4. **npm 超时**: 检查网络连接

## 📝 更新日志

- 2026-03-06: 初始版本，包含 Python/Node.js 编译经验

# Source Build - 龙芯编译专家

**专注 LoongArch 架构特有的编译问题和解决方案**

---

## 🎯 快速开始

| 问题 | 解决方案 |
|------|---------|
| config.sub 不识别 | [docs/arch-fixes.md](docs/arch-fixes.md) |
| 没有 loong64 wheel | [docs/python-wheel.md](docs/python-wheel.md) |
| Rust 下载失败 | [docs/rust-fix.md](docs/rust-fix.md) |
| node-gyp 失败 | [docs/node-gyp.md](docs/node-gyp.md) |
| 需要修改源码 | [docs/source-patching.md](docs/source-patching.md) |
| 项目编译经验 | [docs/projects/](docs/projects/) |

---

## 📚 文档结构

```
docs/
├── arch-fixes.md          # 架构识别问题
├── python-wheel.md        # Python wheel 缺失
├── rust-fix.md           # Rust 编译问题
├── node-gyp.md           # node-gyp 问题
├── source-patching.md    # 源码修改
└── projects/             # 项目经验
    ├── onnxruntime.md
    └── curl-impersonate.md
```

---

## 🛠️ 脚本

```bash
# 环境检查
./scripts/check-env.sh

# 依赖安装
./scripts/install-python-deps.sh
./scripts/install-node-deps.sh
```

---

## 📋 配置

镜像源配置：[snippets/common-configs.md](snippets/common-configs.md)

---

## 💡 典型场景

### Python 包没有 wheel
```bash
# 优先系统包
sudo apt install python3-xxx

# 从源码编译
pip install --no-binary :all: package
```

### config.sub 不识别
```bash
wget -O config.sub "https://git.savannah.gnu.org/git/config.sub"
wget -O config.guess "https://git.savannah.gnu.org/git/config.guess"
chmod +x config.sub config.guess
```

### Rust 下载失败
```bash
sudo apt install rustc cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true
```

---

## 📝 更新日志

- **2026-03-09**: 重构技能结构，删除通用内容，聚焦 LoongArch 特定经验

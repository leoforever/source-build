# Source Build - 龙芯编译专家

**专注 LoongArch 架构特有的编译问题和解决方案**，通用编译流程大模型已知，不赘述。

---

## 🚀 快速决策树

根据用户问题关键词，快速定位解决方案：

```
用户问题
    │
    ├─→ "config.sub 不识别" → docs/arch-fixes.md
    ├─→ "没有 loong64 wheel" → docs/python-wheel.md
    ├─→ "Rust 下载失败" → docs/rust-fix.md
    ├─→ "node-gyp 失败" → docs/node-gyp.md
    ├─→ "编译器特性不支持" → docs/source-patching.md
    ├─→ "sqlite-vec / npm 包缺少支持" → docs/case-sqlite-vec.md
    ├─→ "jemalloc 崩溃/链接错误" → docs/rust-env.md
    ├─→ "Rust 版本过低" → docs/rust-toolchain.md
    ├─→ "依赖版本冲突" → docs/dependency-downgrade.md
    ├─→ "Go 编译/GOPROXY" → docs/go-build.md
    ├─→ "ollama / GGML / LSX 优化" → docs/case-ollama-loongarch.md
    ├─→ "pip 源配置" → docs/pip-sources.md
    ├─→ "Docker 容器编译" → docs/docker-build.md
    └─→ "项目编译经验" → docs/projects/
```

---

## 📚 文档索引

| 文档 | 触发关键词 | 用途 |
|------|-----------|------|
| [docs/arch-fixes.md](docs/arch-fixes.md) | config.sub、架构识别、架构宏 | 架构适配补丁 |
| [docs/python-wheel.md](docs/python-wheel.md) | wheel、pip、no-binary | Python wheel 缺失 |
| [docs/rust-fix.md](docs/rust-fix.md) | Rust、cargo、下载失败 | Rust 编译问题 |
| [docs/rust-toolchain.md](docs/rust-toolchain.md) | rust-version、nightly、工具链 | Rust 版本/工具链 |
| [docs/rust-env.md](docs/rust-env.md) | jemalloc、relocation、RUSTFLAGS | Rust 环境变量 |
| [docs/source-patching.md](docs/source-patching.md) | 条件编译、架构宏、patch | 源码修改补丁 |
| [docs/node-gyp.md](docs/node-gyp.md) | node-gyp、npm、native | Node 原生模块 |
| [docs/case-sqlite-vec.md](docs/case-sqlite-vec.md) | sqlite-vec、npm 包适配 | npm 包平台适配案例 |
| [docs/case-ollama-loongarch.md](docs/case-ollama-loongarch.md) | ollama、GGML、LSX/LASX | Ollama/LLM 编译优化 |
| [docs/dependency-downgrade.md](docs/dependency-downgrade.md) | 依赖冲突、版本降级 | 依赖版本管理 |
| [docs/go-build.md](docs/go-build.md) | Go、GOPROXY、loong64、静态链接 | Go 编译配置 |
| [docs/pip-sources.md](docs/pip-sources.md) | pip 源、龙芯源 | pip 镜像源配置 |
| [docs/docker-build.md](docs/docker-build.md) | Docker、容器、镜像、lcr | Docker 容器编译环境 |
| [docs/verification-template.md](docs/verification-template.md) | 验证报告、文档复现性 | 编译验证报告模板 |
| [docs/projects/](docs/projects/) | onnxruntime、maturin、项目名 | 真实项目经验 |

---

## ⚠️ 核心原则

1. **系统源优先** - 能 apt/yum 就别 pip/npm
2. **升级环境优先** - 能 rustup 就别改代码
3. **降级依赖优先** - 能换版本就别 patch
4. **日志必须记录** - 所有编译过程记日志
5. **先查 skill 再行动** - 遇到问题先读取相关文档，不凭经验推断

---

## 📋 编译前检查清单（强制）

**开始任何编译任务前，必须按顺序检查：**

### Step 1: 识别问题类型

根据问题关键词读取对应文档：
- Node.js 版本/安装 → `docs/node-gyp.md`
- Python 包/wheel → `docs/python-wheel.md`
- Rust 工具链 → `docs/rust-toolchain.md`
- Docker 容器 → `docs/docker-build.md`
- pip 源 → `docs/pip-sources.md`
- Go 模块 → `docs/go-build.md`
- 架构识别 → `docs/arch-fixes.md`

### Step 2: 读取对应文档

**必须读取完整文档**，不要跳过任何章节。

文档中包含：
- ✅ 已验证的解决方案
- ✅ 龙芯平台特有的配置
- ✅ 常见陷阱和避坑指南

### Step 3: 按文档执行

**严格遵循文档步骤**，不要：
- ❌ 使用系统默认版本（如 `dnf install nodejs` 只有 v18）
- ❌ 凭经验推断（如假设 GPG 密钥需要手动导入）
- ❌ 跳过验证步骤

---

## 📝 编译日志规则

所有编译过程必须记录到日志文件：

```bash
LOGFILE="/tmp/build-$(date +%Y%m%d-%H%M%S).log"
cargo build --release 2>&1 | tee -a $LOGFILE
```

详细日志规范见：[docs/projects/template.md](docs/projects/template.md)

### 验证报告

完成编译验证后，应生成验证报告：

```bash
REPORT="/tmp/build-verification-$(date +%Y%m%d-%H%M%S).md"
```

验证报告应包含：
- ✅/❌ 每个步骤是否成功
- 编译产物位置和大小
- 版本号是否正确
- 是否真正静态链接（如适用）
- 文档是否需要更新

---

## 🚨 常见错误示例

### ❌ Node.js 版本问题

**症状：** 使用 `dnf install nodejs` 安装后版本过低

**原因：** 没有先读取 `docs/node-gyp.md`，该文档明确说明龙芯平台 dnf 源只有 Node 18，应使用 unofficial-builds。

**正确做法：**
```bash
wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz
tar -xzf node-v22.20.0-linux-loong64.tar.gz
export PATH=/opt/node-v22.20.0-linux-loong64/bin:$PATH
```

### ❌ GPG 密钥问题

**症状：** 在容器内手动导入 GPG 密钥，但实际不需要

**原因：** 没有先检查 `docs/docker-build.md`，文档说明 loongnix-server 通常已预配置。

---

## 💡 使用示例

**用户:** "cryptography 安装失败"  
→ 读取 `docs/python-wheel.md` → 提供系统包方案

**用户:** "config.sub 报错不识别 loongarch64"  
→ 读取 `docs/arch-fixes.md` → 提供更新脚本

**用户:** "帮我编译 onnxruntime"  
→ 读取 `docs/projects/onnxruntime.md` → 应用补丁 + 编译

**用户:** "polars 需要 Rust 1.80+"  
→ 读取 `docs/rust-toolchain.md` → 升级 Rust

---

## 📁 目录结构

```
source-build/
├── SKILL.md              # 技能主文件（行为定义）
├── README.md             # 本文件
├── docs/
│   ├── arch-fixes.md            # 架构适配补丁
│   ├── python-wheel.md          # Python wheel 缺失
│   ├── rust-fix.md              # Rust 编译问题
│   ├── rust-toolchain.md        # Rust 版本/工具链
│   ├── rust-env.md              # Rust 环境变量
│   ├── source-patching.md       # 源码修改补丁
│   ├── node-gyp.md              # Node 原生模块
│   ├── case-sqlite-vec.md       # npm 包平台适配案例
│   ├── case-ollama-loongarch.md # Ollama/LLM 编译优化
│   ├── dependency-downgrade.md  # 依赖版本管理
│   ├── go-build.md              # Go 编译配置
│   ├── pip-sources.md           # pip 镜像源配置
│   ├── docker-build.md          # Docker 容器编译环境
│   ├── verification-template.md # 编译验证报告模板
│   └── projects/                # 真实项目经验
│       ├── onnxruntime.md
│       ├── curl-impersonate.md
│       └── template.md
└── snippets/
    └── common-configs.md   # 常用配置片段
```

---

## 📝 更新日志

- **2026-04-03**: 重构技能文档，新增决策树导航和 15+ 专题文档
  - 新增架构适配、Rust 工具链、Docker 编译等专题文档
  - 新增 onnxruntime、curl-impersonate 真实项目案例
  - 新增编译验证报告模板和日志规范
  - 删除冗余文档，精简结构提升可维护性

- **2026-03-09**: 重构技能结构，删除通用内容，聚焦 LoongArch 特定经验

---

*完整技能文档，按需加载子文档*

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


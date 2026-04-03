# 龙芯 Rust 编译环境变量

**在龙芯 LoongArch 平台编译 Rust 程序时，必须设置以下环境变量**，确保与系统 glibc 兼容并避免链接错误。

---

## 🔧 环境变量设置

```bash
# Rust 编译标志
export RUSTFLAGS="--cfg tikv_jemalloc_sys_no_jemalloc --cfg feature=\"disable-jemalloc\" -C link-arg=-Wl,-no-relax"

# C/C++ 编译标志（龙芯 medium 内存模型）
export CFLAGS="-mcmodel=medium"
export CXXFLAGS="-mcmodel=medium"
```

---

## 📋 参数说明

| 参数 | 作用 | 必要性 |
|------|------|--------|
| `--cfg tikv_jemalloc_sys_no_jemalloc` | 禁用 tikv-jemalloc-sys 的 jemalloc | ⚠️ 龙芯必需 |
| `--cfg feature="disable-jemalloc"` | 全局禁用 jemalloc，使用系统分配器 | ⚠️ 龙芯必需 |
| `-C link-arg=-Wl,-no-relax` | 禁用链接器 relax 优化，避免重定位错误 | ⚠️ 龙芯必需 |
| `-mcmodel=medium` | 使用中等内存模型，支持大地址空间 | ⚠️ 龙芯必需 |

---

## ❓ 为什么需要这些设置？

### 1. jemalloc 问题

tikv-jemalloc 在龙芯平台存在兼容性问题，可能导致崩溃：

```
Segmentation fault (core dumped)
  at jemalloc allocation
```

**解决**：设置 `--cfg tikv_jemalloc_sys_no_jemalloc` 禁用 jemalloc，使用系统分配器。

### 2. Relax 优化问题

LoongArch 链接器 relax 优化可能导致重定位错误：

```
error: R_LARCH_* relocation error
```

**解决**：设置 `-C link-arg=-Wl,-no-relax` 禁用 relax 优化。

### 3. 内存模型

medium 模型支持 2MB-2GB 代码段，适合大型项目：

```
error: relocation truncated to fit
```

**解决**：设置 `-mcmodel=medium` 使用中等内存模型。

---

## 💡 使用场景

### 场景 1：编译 Rust 项目

```bash
cd /path/to/rust-project
export RUSTFLAGS="--cfg tikv_jemalloc_sys_no_jemalloc --cfg feature=\"disable-jemalloc\" -C link-arg=-Wl,-no-relax"
export CFLAGS="-mcmodel=medium"
export CXXFLAGS="-mcmodel=medium"
cargo build --release 2>&1 | tee build.log
```

### 场景 2：编译带 native 扩展的 Python 包

```bash
export RUSTFLAGS="--cfg tikv_jemalloc_sys_no_jemalloc --cfg feature=\"disable-jemalloc\" -C link-arg=-Wl,-no-relax"
export CFLAGS="-mcmodel=medium"
export CXXFLAGS="-mcmodel=medium"
pip install --no-binary :all: maturin 2>&1 | tee pip-build.log
```

### 场景 3：混合编译项目（Rust + C/C++）

```bash
export RUSTFLAGS="--cfg tikv_jemalloc_sys_no_jemalloc --cfg feature=\"disable-jemalloc\" -C link-arg=-Wl,-no-relax"
export CFLAGS="-mcmodel=medium"
export CXXFLAGS="-mcmodel=medium"
./configure && make -j$(nproc) 2>&1 | tee make-build.log
```

---

## 📦 持久化配置

### 方式 1：shell 配置文件

```bash
cat >> ~/.bashrc << 'EOF'

# 龙芯 Rust 编译环境变量
if [ "$(uname -m)" = "loongarch64" ]; then
    export RUSTFLAGS="--cfg tikv_jemalloc_sys_no_jemalloc --cfg feature=\"disable-jemalloc\" -C link-arg=-Wl,-no-relax"
    export CFLAGS="-mcmodel=medium"
    export CXXFLAGS="-mcmodel=medium"
fi
EOF

source ~/.bashrc
```

### 方式 2：Cargo 配置（仅 Rust 项目）

```bash
mkdir -p ~/.cargo
cat >> ~/.cargo/config.toml << 'EOF'

# 龙芯 LoongArch 平台特定配置
[target.loongarch64-unknown-linux-gnu]
rustflags = [
    "--cfg", "tikv_jemalloc_sys_no_jemalloc",
    "--cfg", "feature=\"disable-jemalloc\"",
    "-C", "link-arg=-Wl,-no-relax"
]

[build]
# 使用 medium 内存模型
rustflags = ["-C", "code-model=medium"]
EOF
```

---

## ❗ 已知问题

| 问题 | 错误信息 | 解决方案 |
|------|---------|---------|
| jemalloc 崩溃 | `Segmentation fault` in jemalloc | 设置 `tikv_jemalloc_sys_no_jemalloc` |
| 链接错误 | `relocation truncated to fit` | 设置 `-mcmodel=medium` |
| relax 优化错误 | `R_LARCH_* relocation error` | 设置 `-no-relax` |

---

## ✅ 验证配置

```bash
# 检查环境变量
echo $RUSTFLAGS
echo $CFLAGS
echo $CXXFLAGS

# 验证 Rust 配置
rustc --print cfg | grep -E "target_arch|target_os"

# 测试编译
cargo new test-loongson && cd test-loongson
cargo build --release 2>&1 | tee test-build.log
```

---

## 🔗 相关文档

- [rust-fix.md](rust-fix.md) - Rust 下载和编译问题
- [rust-toolchain.md](rust-toolchain.md) - Rust 工具链版本管理
- [../SKILL.md](../SKILL.md) - 主技能文档

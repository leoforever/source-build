# Rust 工具链版本管理

**适用场景**：项目需要特定 Rust 版本、nightly 工具链、rust-version 不匹配

---

## 📋 版本要求类型

| 要求类型 | 示例 | 含义 | 升级策略 |
|---------|------|------|---------|
| **最低版本** | `rust-version = "1.80"` | 需要 Rust 1.80+ | 升级到最新 stable ✅ |
| **精确日期** | `nightly-2024-05-14` | 需要该日期的 nightly | 安装指定日期版本 ✅ |
| **通道要求** | `channel = "nightly"` | 需要 nightly 通道 | 安装最新 nightly ✅ |

---

## 🔧 典型案例

### 案例 1：Polars 需要 nightly-2024-05-14

**问题现象：**
```
The project requires nightly-2024-05-14. Current Rust is 1.77.0 (stable).
error[E0554]: `#![feature]` may not be used on the stable release channel
```

**✅ 正确做法：**
```bash
# 1. 检查项目需要的工具链版本
cat rust-toolchain.toml
# 输出：channel = "nightly-2024-05-14"

# 2. 升级 rustup 到最新版
rustup self update

# 3. 安装项目指定的 nightly 版本
rustup install nightly-2024-05-14
rustup default nightly-2024-05-14

# 4. 验证
rustc --version
# 应输出：rustc 1.80.0-nightly (xxx 2024-05-14)

# 5. 编译
cargo build --release
```

### 案例 2：项目需要 Rust 1.80+（最低版本）

**问题现象：**
```
error: Rust 1.80 or higher is required
Current: rustc 1.77.0
```

**✅ 正确做法：**
```bash
# 1. 检查 Cargo.toml
cat Cargo.toml | grep "rust-version"
# 输出：rust-version = "1.80"

# 2. 升级 rustup
rustup self update

# 3. 安装最新 stable（高于 1.80）
rustup install stable
rustup default stable

# 4. 验证（应 >= 1.80）
rustc --version
# 输出：rustc 1.94.0 ✅

# 5. 编译
cargo build --release
```

---

## 🎯 决策流程

```
编译报错：工具链版本不匹配
    │
    ├─→ 检查 rust-toolchain.toml
    │       │
    │       ├─→ nightly-YYYY-MM-DD → 检查当前是否是该日期版本
    │       │       ├─→ 是 → 无需升级 ✅
    │       │       └─→ 否 → rustup install nightly-YYYY-MM-DD ✅
    │       │
    │       ├─→ channel = "nightly" → 检查当前是否 nightly
    │       │       ├─→ 是 → 无需升级 ✅
    │       │       └─→ 否 → rustup install nightly ✅
    │       │
    │       └─→ channel = "stable" → 检查版本是否满足要求
    │               ├─→ 满足 → 无需升级 ✅
    │               └─→ 不满足 → rustup install stable ✅
    │
    ├─→ 没有 rust-toolchain.toml？检查 Cargo.toml
    │       │
    │       ├─→ rust-version = "1.80" → 检查当前版本
    │       │       ├─→ 当前版本 >= 1.80 → 无需升级 ✅
    │       │       └─→ 当前版本 < 1.80 → rustup install stable ✅
    │       │
    │       └─→ 都没有 → 查看 README / 文档
    │
    └─→ 重新编译
```

**核心原则**：
- 能升级环境就别改代码
- 现有版本满足要求时无需升级
- 永远不要修改源码适配旧版本编译器

---

## 📦 操作模板

### 检查并安装项目需要的 Rust 工具链

```bash
setup_rust_toolchain() {
    local project_dir=$1
    cd "$project_dir"
    
    # 检查 rust-toolchain.toml
    if [ -f "rust-toolchain.toml" ]; then
        echo "发现 rust-toolchain.toml，读取工具链要求..."
        local channel=$(grep -E "^channel\s*=" rust-toolchain.toml | cut -d'"' -f2)
        echo "项目需要：$channel"
        
        # 安装指定工具链
        rustup install "$channel"
        rustup default "$channel"
        
    # 检查 Cargo.toml 的 rust-version
    elif grep -q "rust-version" Cargo.toml; then
        echo "检查 Cargo.toml 的 rust-version..."
        local version=$(grep "rust-version" Cargo.toml | cut -d'"' -f2)
        echo "项目需要 Rust >= $version"
        
        # 安装 stable（通常 rust-version 指的是 stable）
        rustup install stable
        rustup default stable
    else
        echo "未发现工具链要求，使用 stable"
        rustup install stable
        rustup default stable
    fi
    
    # 验证
    rustc --version
}

# 使用示例
setup_rust_toolchain /tmp/polars
```

### Rust 升级脚本（智能版本检查）

```bash
upgrade_rust_if_needed() {
    local required_version=$1
    
    # 获取当前版本
    local current_version=$(rustc --version | awk '{print $2}')
    
    echo "当前 Rust 版本：$current_version"
    echo "项目需要版本：$required_version"
    
    # 版本比较（简化处理：比较主版本号）
    local current_major=$(echo $current_version | cut -d. -f1)
    local required_major=$(echo $required_version | cut -d. -f1)
    local current_minor=$(echo $current_version | cut -d. -f2)
    local required_minor=$(echo $required_version | cut -d. -f2)
    
    if [ "$current_major" -gt "$required_major" ] || \
       ([ "$current_major" -eq "$required_major" ] && [ "$current_minor" -ge "$required_minor" ]); then
        echo "✅ 当前版本 ($current_version) >= 要求版本 ($required_version)，无需升级"
        return 0
    else
        echo "版本过低，正在升级..."
        source $HOME/.cargo/env
        rustup update stable
        rustup default stable
        rustc --version
    fi
}

# 使用示例
upgrade_rust_if_needed "1.80.0"
# 输出：当前版本 1.94.0 >= 要求版本 1.80.0，无需升级 ✅
```

---

## 🔧 rustup 常用命令

```bash
# 查看当前工具链
rustup show

# 列出已安装的工具链
rustup toolchain list

# 安装特定日期的 nightly
rustup install nightly-2024-05-14

# 设置默认工具链
rustup default nightly-2024-05-14

# 为当前目录设置临时工具链（仅在该目录下生效）
rustup override set nightly-2024-05-14

# 取消目录覆盖
rustup override unset

# 删除旧工具链
rustup toolchain uninstall nightly-2024-04-01
```

---

## 📋 rust-toolchain.toml 示例

```toml
# 方式 1: 指定日期版本
[toolchain]
channel = "nightly-2024-05-14"
components = ["rust-src", "rustfmt", "clippy"]
targets = ["loongarch64-unknown-linux-gnu"]

# 方式 2: 指定 stable 版本
[toolchain]
channel = "1.78.0"

# 方式 3: 简单写法（只有 channel）
[toolchain]
channel = "nightly"
```

---

## 📊 常见项目的工具链要求

| 项目 | 工具链要求 | 检查方式 | 安装命令 |
|------|-----------|---------|---------|
| Polars (旧版) | nightly-2024-05-14 | rust-toolchain.toml | `rustup install nightly-2024-05-14` |
| Polars (新版) | stable 1.80+ | Cargo.toml | `rustup install stable` |
| tokio | stable | Cargo.toml | `rustup install stable` |
| bevy | nightly | rust-toolchain.toml | 按文件指定版本 |
| onnxruntime | stable 1.70+ | Cargo.toml | `rustup install stable` |
| maturin | stable 1.74+ | Cargo.toml | `rustup install stable` |

---

## ⚠️ 注意事项

1. **rust-toolchain.toml 优先级最高**：如果项目有这个文件，rustup 会自动使用指定的工具链

2. **目录覆盖（override）**：使用 `rustup override set` 可以为特定项目目录设置独立工具链，不影响全局

3. **组件完整性**：某些项目需要额外组件（如 rust-src），按 rust-toolchain.toml 中的 components 字段安装

4. **龙芯 loongarch64 架构**：
   ```bash
   # 添加 loongarch64 目标支持
   rustup target add loongarch64-unknown-linux-gnu --toolchain nightly-2024-05-14
   ```

5. **网络慢？** 配置镜像：
   ```bash
   export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
   export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
   ```

6. **rustup 未安装？** 先安装 rustup：
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

7. **升级后编译仍失败？** 清理 cargo 缓存：
   ```bash
   cargo clean
   cargo build --release
   ```

---

## 🔗 相关文档

- [rust-fix.md](rust-fix.md) - Rust 下载和编译问题
- [rust-env.md](rust-env.md) - Rust 环境变量配置
- [../SKILL.md](../SKILL.md) - 主技能文档

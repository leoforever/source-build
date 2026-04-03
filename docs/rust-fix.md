# Rust 编译问题修复

> 解决 Rust 下载失败和编译问题

---

## 问题症状

```
error: failed to download file
error=Reqwest(reqwest::Error { 
  kind: Request, 
  url: "https://static.rust-lang.org/...",
  source: ... dns error ...
})
```

**原因:** 无法访问 static.rust-lang.org（DNS 解析问题）

---

## 解决方案

### 方案 1: 使用系统 Rust（推荐）

```bash
sudo apt install rustc cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true
pip install package
```

**适用:** cryptography、maturin 等需要 Rust 的 Python 包

---

### 方案 2: 配置镜像源

```bash
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

curl --proto '=https' --tlsv1.2 -sSf \
    https://mirrors.ustc.edu.cn/rust-static/rustup/rustup-init.sh | sh
```

---

### 方案 3: 使用预编译包

```bash
# cryptography
sudo apt install python3-cryptography

# maturin（如果系统包可用）
sudo apt install maturin
```

---

## 编译加速

```bash
# 使用 sccache 缓存
sudo apt install sccache
export RUSTC_WRAPPER=sccache

# 并行编译
export CARGO_BUILD_JOBS=$(nproc)
```

---

## maturin 项目适配

maturin 现已原生支持 LoongArch，**不需要补丁**：

```bash
# 直接使用
pip install maturin
maturin build --release

# 早期版本的补丁（已不需要，保留参考）
# curl -sL https://patch-url | patch -p1
```

**经验:**
- ✅ 优先等待上游支持
- ✅ 定期检查是否可以移除补丁
- ✅ 上游支持后及时清理

---

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| DNS 解析失败 | 使用系统 Rust |
| 编译慢 | sccache 缓存 |
| 找不到 cargo | apt install cargo |
| 版本太旧 | 使用 rustup + 镜像 |

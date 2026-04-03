# curl-impersonate LoongArch 适配经验

> 基于 Loongson-Cloud-Community 实际适配经验

---

## 核心问题

### 1. brotli 编译问题

**症状:**
```
error: 'model' attribute is not supported on this target
```

**原因:** `model` 属性在 LoongArch 上不支持

**修复:**
```c
// 修改前
#if BROTLI_GNUC_HAS_ATTRIBUTE(model, 3, 0, 3)

// 修改后 - 排除不支持的平台
#if !defined(BROTLI_MODEL) && \
    BROTLI_GNUC_HAS_ATTRIBUTE(model, 3, 0, 3) && \
    !defined(BROTLI_TARGET_IA64) && \
    !defined(BROTLI_TARGET_LOONGARCH64)
```

**补丁文件:** `patches/brotli-loongarch.patch`

---

### 2. BoringSSL 适配

**问题:** 缺少 LoongArch 架构定义

**修复:**
```c
// include/openssl/target.h
#elif defined(__loongarch64)
    #define OPENSSL_LOONGARCH64
    #define OPENSSL_64_BIT
#elif defined(__loongarch__)
    #define OPENSSL_LOONGARCH
    #define OPENSSL_32_BIT
```

**补丁文件:** `patches/boringssl-loongarch.patch`

---

## 构建系统支持

```makefile
# 添加补丁机制
brotli-$(BROTLI_VERSION)/.patched: $(srcdir)/patches/brotli.patch
	tar xf brotli-$(BROTLI_VERSION).tar.gz
	cd brotli-$(BROTLI_VERSION)
	for p in $^; do patch -p1 < $$p; done
	touch .patched
```

**说明:** 使用 `.patched` 标记文件避免重复打补丁

---

## CI 配置

```yaml
# GitHub Actions
jobs:
  build:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            platform: linux
            arch: loongarch64
            host: loongarch64-linux-gnu
            zigflags: -target loongarch64-linux-gnu.2.36 -fPIC

    steps:
      - name: Setup toolchain
        run: |
          sudo apt-get update
          sudo apt-get install -y gcc-loongarch64-linux-gnu g++-loongarch64-linux-gnu

      - name: Build
        run: |
          make CC=loongarch64-linux-gnu-gcc CXX=loongarch64-linux-gnu-g++
```

---

## 关键经验

### ✅ 编译器特性检测
某些特性（如 `model` 属性）在 LoongArch 上不可用，需要条件编译排除

### ✅ 架构宏定义
添加 `OPENSSL_LOONGARCH64` 等宏定义

### ✅ 补丁标记
使用 `.patched` 文件避免重复应用

### ✅ Zig 交叉编译
```bash
zig cc -target loongarch64-linux-gnu.2.36 -fPIC
```

---

## 参考资源

- GitHub: Loongson-Cloud-Community/curl-impersonate
- 补丁目录：`patches/`

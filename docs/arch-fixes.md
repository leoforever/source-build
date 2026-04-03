# 架构识别问题修复

> 解决 LoongArch 不被识别的问题

---

## 问题 1: config.sub/config.guess 不识别

**症状:**
```
checking build system type... Invalid configuration `loongarch64-linux-gnu'
machine `loongarch64' not recognized
configure: error: /bin/sh build-aux/config.sub loongarch64-linux-gnu failed
```

**原因:** autotools 配置文件过旧

**解决方案:**
```bash
# 方法 1: 更新到最新版本（推荐）
wget -O config.sub "https://git.savannah.gnu.org/git/config.sub"
wget -O config.guess "https://git.savannah.gnu.org/git/config.guess"
chmod +x config.sub config.guess

# 方法 2: 使用 autoreconf
sudo apt install autoconf automake
autoreconf -fi
```

**适用场景:**
- Python 3.8 及更早版本
- 旧版本 C/C++ 项目
- 使用 autotools 的项目

---

## 问题 2: 缺少架构宏定义

**症状:**
```
#error "Unsupported architecture"
#error "Unknown CPU type"
```

**解决方案:**
```c
// 添加 LoongArch 架构定义
#if defined(__loongarch64)
    #define ARCH_LOONGARCH64
    #define ARCH_64BIT
#elif defined(__loongarch__)
    #define ARCH_LOONGARCH
    #define ARCH_32BIT
#endif

// 在架构检测链中添加
#ifdef __x86_64__
    // x86_64
#elif defined(__aarch64__)
    // ARM64
#elif defined(__loongarch64)
    // LoongArch64 ⬅️ 新增
#else
    #error "Unsupported architecture"
#endif
```

**实际案例 (BoringSSL):**
```c
// include/openssl/target.h
#elif defined(__loongarch64)
    #define OPENSSL_LOONGARCH64
    #define OPENSSL_64_BIT
```

---

## 问题 3: 编译器特性不支持

**症状:**
```
error: 'model' attribute is not supported on this target
error: unsupported inline asm
```

**解决方案:**
```c
// 添加条件编译
#if defined(__loongarch__)
    // LoongArch 实现
#else
    // 原始实现
#endif
```

**实际案例 (brotli):**
```c
// 修改前
#if BROTLI_GNUC_HAS_ATTRIBUTE(model, 3, 0, 3)

// 修改后 - 排除不支持的平台
#if !defined(BROTLI_MODEL) && \
    BROTLI_GNUC_HAS_ATTRIBUTE(model, 3, 0, 3) && \
    !defined(BROTLI_TARGET_IA64) && \
    !defined(BROTLI_TARGET_LOONGARCH64)
```

---

## 问题 4: CMake 找不到工具链

**症状:**
```
CMake Error: Could not find CMAKE_C_COMPILER
```

**解决方案:**
```bash
# 方法 1: 指定编译器
cmake -DCMAKE_C_COMPILER=loongarch64-linux-gnu-gcc \
      -DCMAKE_CXX_COMPILER=loongarch64-linux-gnu-g++ ..

# 方法 2: 工具链文件
cat > toolchain-loongarch64.cmake << 'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR loongarch64)
set(CMAKE_C_COMPILER loongarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER loongarch64-linux-gnu-g++)
EOF

cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-loongarch64.cmake ..

# 方法 3: 安装工具链
sudo apt install gcc-loongarch64-linux-gnu g++-loongarch64-linux-gnu
```

---

## 问题 5: Zig 交叉编译

```bash
# 正确的目标三元组
zig cc -target loongarch64-linux-gnu.2.36 -fPIC
zig c++ -target loongarch64-linux-gnu.2.36 -fPIC

# .2.36 表示 glibc 2.36
```

---

## 架构检测宏参考

```c
// GCC/Clang 预定义宏
__loongarch64    // LoongArch64
__loongarch__    // LoongArch (通用)
__loongarch_sx   // 支持 SX 扩展

// 检测示例
#if defined(__loongarch64)
    #define TARGET_LOONGARCH64
#elif defined(__loongarch__)
    #define TARGET_LOONGARCH
#endif
```

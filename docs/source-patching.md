# 源码修改与 Patch 应用

> LoongArch 特定的源码修改模式

---

## 适用场景

1. 编译错误但无预编译方案
2. 架构特定问题（需要添加 LoongArch 支持）
3. 编译器特性不支持
4. 依赖库版本不兼容

---

## Patch 应用方法

### 标准流程

```bash
# 1. 下载源码
wget https://example.com/package-1.2.3.tar.gz
tar -xzf package-1.2.3.tar.gz
cd package-1.2.3

# 2. 应用 patch
wget https://example.com/fix.patch
patch -p1 < fix.patch

# 3. 验证
patch -p1 --dry-run < fix.patch  # 预演
```

### 批量应用（带标记）

```bash
#!/bin/bash
# apply-patches.sh

if [ ! -f ".patched" ]; then
    for patch in patches/*.patch; do
        echo "Applying: $patch"
        patch -p1 < "$patch" || exit 1
    done
    touch .patched
else
    echo "Patches already applied"
fi
```

---

## 常见修改模式

### 1. 架构检测宏

```c
// 添加 LoongArch 定义
#if defined(__loongarch64)
    #define ARCH_LOONGARCH64
    #define ARCH_64BIT
#elif defined(__loongarch__)
    #define ARCH_LOONGARCH
    #define ARCH_32BIT
#endif

// 在架构检测链中
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

---

### 2. 条件编译（排除不支持的特性）

```c
// brotli 案例：排除 model 属性
#if !defined(BROTLI_MODEL) && \
    BROTLI_GNUC_HAS_ATTRIBUTE(model, 3, 0, 3) && \
    !defined(BROTLI_TARGET_IA64) && \
    !defined(BROTLI_TARGET_LOONGARCH64)
    // 使用 model 属性
#endif
```

---

### 3. C99 兼容性

```c
// 问题：隐式函数声明
// 错误：implicit declaration of function 'sbrk'
// 修复：添加头文件
#include <unistd.h>

// 问题：main() 返回类型
// 错误：'main' must return 'int'
// 修复：
int main(void) { ... return 0; }
```

---

### 4. 格式说明符（64 位类型）

```c
// 错误：format '%d' expects 'int'
// 修复：使用正确的格式说明符
printf("value: %llu", (unsigned long long)state->loc);
```

---

### 5. 端序处理

```python
# 错误：硬编码小端序
# 修复：动态获取端序
import sys
endian = '<' if sys.byteorder == 'little' else '>'
dtype = f"{endian}f8"
```

---

## LoongArch 特定修改

### greenlet（协程栈切换）

**新增文件:** `src/greenlet/platform/switch_loongarch64_linux.h`

```c
#define STACK_REFPLUS 1

#define REGS_TO_SAVE "s0", "s1", "s2", "s3", "s4", "s5", \
                    "s6", "s7", "s8", "fp", \
                    "f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31"

static int slp_switch(void) {
    register int ret;
    register long *stackref, stsizediff;
    __asm__ volatile ("move %0, $sp" : "=r" (stackref) : );
    {
        SLP_SAVE_STATE(stackref, stsizediff);
        __asm__ volatile ("add.d $sp, $sp, %0" : : "r" (stsizediff));
        SLP_RESTORE_STATE();
    }
    __asm__ volatile ("move %0, $zero" : "=r" (ret) : );
    return ret;
}
```

**架构识别:**
```c
// src/greenlet/slp_platformselect.h
#elif defined(__GNUC__) && defined(__loongarch64) && defined(__linux__)
#include "platform/switch_loongarch64_linux.h"
```

---

### ujson（浮点操作支持）

```c
// deps/double-conversion/double-conversion/utils.h
// 添加 __loongarch64 到支持的架构列表
defined(__riscv) || defined(__loongarch64)
#define DOUBLE_CONVERSION_CORRECT_DOUBLE_OPERATIONS 1
```

---

### nova（OpenStack 虚拟化支持）

```python
# nova/virt/arch.py
LOONGARCH64 = 'loongarch64'

# nova/virt/libvirt/driver.py
elif arch == fields.Architecture.LOONGARCH64:
    mode = 'la464'

# UEFI 支持
if arch == fields.Architecture.AARCH64 or arch == fields.Architecture.LOONGARCH64:
    hw_firmware_type = fields.FirmwareType.UEFI
```

---

## 补丁管理最佳实践

### 目录结构

```
patches/
├── python/
│   ├── python38-loongarch.patch
│   └── python39-310-loongarch.patch
├── brotli-loongarch.patch
└── openssl-loongarch.patch
```

### 版本特定补丁

```bash
#!/bin/bash
case "$VERSION" in
    3.8*)
        apply_patch "patches/python/python38-loongarch.patch"
        ;;
    3.9*|3.10*)
        apply_patch "patches/python/python39-310-loongarch.patch"
        ;;
esac
```

### 维护建议

1. **定期检查上游支持** - 上游合并后及时移除本地补丁
2. **记录适用范围** - 注明补丁适用的版本范围
3. **自动化测试** - CI 中测试补丁是否能干净应用

---

## 错误快速索引

| 错误 | 原因 | 修复 |
|------|------|------|
| `implicit declaration` | 缺少头文件 | 添加 `#include` |
| `'main' must return 'int'` | C99 兼容性 | `int main(void)` |
| `format '%d' expects 'int'` | 64 位类型 | `%llu` / `%lld` |
| `unsupported architecture` | 未识别架构 | 添加架构宏 |
| `RPATH warning` | 硬编码路径 | 移除 `library_dirs` |

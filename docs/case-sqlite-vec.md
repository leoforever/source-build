# 案例：sqlite-vec loong64 架构编译与 npm 包适配

**问题类型**：npm 包缺少 loong64 预编译文件 + SQLite 扩展编译

**适用场景**：
- npm/Node.js 包缺少 loong64 架构支持
- 需要为 npm 包添加自定义平台支持
- SQLite 扩展编译和符号名问题
- OpenClaw/记忆系统向量搜索扩展

---

## 📋 问题描述

在 loong64 架构上安装和使用 `sqlite-vec` npm 包时遇到以下问题：

```
sqlite-vec unavailable: Loadble extension for sqlite-vec not found.
Was the sqlite-vec-linux-loong64 package installed?
```

**根本原因**：
1. npm 包没有 loong64 预编译文件
2. 平台检测代码不识别 loong64 架构
3. 编译的扩展符号名与预期不匹配

---

## 🔧 解决方案

### 步骤 1：编译 sqlite-vec 源码

```bash
cd /tmp
git clone --depth 1 https://github.com/asg017/sqlite-vec.git sqlite-vec-build
cd sqlite-vec-build
make loadable
```

**产物**：`/tmp/sqlite-vec-build/dist/vec0.so`

**关键点**：
- 使用 `make loadable` 编译为 SQLite 可扩展模块
- 编译产物默认名为 `vec0.so`

---

### 步骤 2：诊断符号名问题

**问题现象**：
```
undefined symbol: sqlite3_sqliteveclinuxloong_init
```

**诊断命令**：
```bash
nm -D /tmp/sqlite-vec-build/dist/vec0.so | grep -i init
# 输出：0000000000019648 T sqlite3_vec_init
```

**根本原因**：
- sqlite-vec 的平台包命名规则：`sqlite-vec-{os}-{arch}`
- 加载时期望符号：`sqlite3_{platform_name}_init`
- 命名 `sqlite-vec-linux-loong64.so` → 期望 `sqlite3_sqliteveclinuxloong_init`
- 实际符号是 `sqlite3_vec_init`

**解决方法**：使用 `vec0.so` 作为文件名（通用名称，不触发平台符号派生）

---

### 步骤 3：修补 npm 包添加 loong64 支持

**需要修改的位置**（所有 sqlite-vec 安装位置）：

```bash
# 查找所有 sqlite-vec 位置
find /root -name "sqlite-vec" -type d 2>/dev/null | grep node_modules
```

典型位置：
```
/root/.openclaw/workspace/node_modules/.pnpm/sqlite-vec@*/node_modules/sqlite-vec/
/root/.local/share/pnpm/global/5/.pnpm/sqlite-vec@*/node_modules/sqlite-vec/
/root/openclaw*/node_modules/.pnpm/sqlite-vec@*/node_modules/sqlite-vec/
```

**修改 index.cjs**：

```javascript
// 1. 添加 loong64 到支持平台列表
const supportedPlatforms = [
  ["macos","aarch64"],["linux","aarch64"],
  ["macos","x86_64"],["windows","x86_64"],
  ["linux","x86_64"],["linux","loong64"]  // ← 添加这行
];

// 2. 在 getLoadablePath() 中添加 loong64 特殊处理
function getLoadablePath() {
  if (!validPlatform(platform, arch)) {
    throw new Error(invalidPlatformErrorMessage);
  }
  // ← 添加这段 loong64 特殊逻辑
  if (platform === "linux" && arch === "loong64") {
    const loadablePath = join(__dirname, "vec0.so");
    if (statSync(loadablePath, { throwIfNoEntry: false })) {
      return loadablePath;
    }
    throw new Error(extensionNotFoundErrorMessage("vec0"));
  }
  // ... 原有逻辑
}
```

**修改 index.mjs**（ESM 版本，同样的修改）：

```javascript
// 同样添加 loong64 到 supportedPlatforms
// 同样在 getLoadablePath() 中添加 loong64 特殊处理
```

**自动化脚本**：

```bash
#!/bin/bash
# 批量修补所有 sqlite-vec 位置

for dir in $(find /root -name "sqlite-vec" -type d 2>/dev/null | grep node_modules); do
  if [ -f "$dir/index.cjs" ]; then
    # 添加 loong64 到支持平台
    sed -i 's/\["linux","x86_64"\]/["linux","x86_64"],["linux","loong64"]/' "$dir/index.cjs"
    sed -i 's/\["linux","x86_64"\]/["linux","x86_64"],["linux","loong64"]/' "$dir/index.mjs"
    
    # 添加 loong64 特殊处理（略，参考上面的代码）
    echo "✅ Patched: $dir"
  fi
done
```

---

### 步骤 4：部署编译好的扩展

```bash
# 复制 vec0.so 到所有 sqlite-vec 包位置
for dir in \
  /root/.openclaw/workspace/node_modules/.pnpm/sqlite-vec@*/node_modules/sqlite-vec \
  /root/.local/share/pnpm/global/5/.pnpm/sqlite-vec@*/node_modules/sqlite-vec \
  /root/openclaw*/node_modules/.pnpm/sqlite-vec@*/node_modules/sqlite-vec
do
  if [ -d "$dir" ]; then
    cp /tmp/sqlite-vec-build/dist/vec0.so "$dir/vec0.so"
    echo "✅ Copied to $dir"
  fi
done
```

---

### 步骤 5：验证修复

```bash
# 1. SQLite 直接加载测试
sqlite3 :memory: ".load /path/to/vec0.so" "SELECT vec_version();"
# 输出：v0.1.7 ✅

# 2. Node.js 模块加载测试
cd /root/.openclaw/workspace
node -e "const sv = require('sqlite-vec'); console.log(sv.getLoadablePath());"
# 输出：/path/to/vec0.so ✅

# 3. OpenClaw memory status
openclaw memory status --deep
# 输出：Vector: ready ✅
```

---

## 🎯 关键要点

### 1. 符号名问题

| 文件名 | 期望符号 | 实际符号 | 结果 |
|--------|---------|---------|------|
| `sqlite-vec-linux-loong64.so` | `sqlite3_sqliteveclinuxloong_init` | `sqlite3_vec_init` | ❌ 失败 |
| `vec0.so` | `sqlite3_vec_init` | `sqlite3_vec_init` | ✅ 成功 |

**经验**：使用通用文件名 `vec0.so` 避免平台符号派生问题。

### 2. npm 包平台适配模式

```javascript
// 标准模式：添加架构到支持列表
const supportedPlatforms = [
  // ... 其他平台
  ["linux","loong64"]  // ← 添加
];

// 特殊处理：直接返回本地编译的扩展
if (platform === "linux" && arch === "loong64") {
  return join(__dirname, "vec0.so");
}
```

### 3. 多位置同步

npm/pnpm 会在多个位置安装包，需要确保所有位置都修补：
- 工作区 node_modules
- 全局 pnpm 目录
- OpenClaw 安装目录

---

## 📦 完整修复脚本

```bash
#!/bin/bash
set -e

echo "=== sqlite-vec loong64 修复脚本 ==="

# 1. 编译 sqlite-vec
echo ">>> 编译 sqlite-vec..."
cd /tmp
rm -rf sqlite-vec-build
git clone --depth 1 https://github.com/asg017/sqlite-vec.git sqlite-vec-build
cd sqlite-vec-build
make loadable

# 2. 定义所有需要修改的位置
DIRS=()
while IFS= read -r dir; do
  DIRS+=("$dir")
done < <(find /root -name "sqlite-vec" -type d 2>/dev/null | grep node_modules)

# 3. 复制 vec0.so 到所有位置
echo ">>> 复制 vec0.so..."
for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    cp /tmp/sqlite-vec-build/dist/vec0.so "$dir/vec0.so"
    echo "✅ Copied to $dir"
  fi
done

# 4. 修补 index.cjs 和 index.mjs
echo ">>> 修补 index.cjs 和 index.mjs..."
for dir in "${DIRS[@]}"; do
  if [ -f "$dir/index.cjs" ]; then
    # 添加 loong64 到 supportedPlatforms
    sed -i 's/\["linux","x86_64"\]/["linux","x86_64"],["linux","loong64"]/' "$dir/index.cjs"
    sed -i 's/\["linux","x86_64"\]/["linux","x86_64"],["linux","loong64"]/' "$dir/index.mjs"
    echo "✅ Patched $dir"
  fi
done

echo "=== 修复完成 ==="

# 5. 验证
echo ">>> 验证..."
sqlite3 :memory: ".load /tmp/sqlite-vec-build/dist/vec0.so" "SELECT vec_version();"
```

---

## 🔗 相关文档

- [arch-fixes.md](arch-fixes.md) - 架构识别问题
- [source-patching.md](source-patching.md) - 源码修改和补丁
- [rust-fix.md](rust-fix.md) - Rust 编译问题

---

## 📝 适用场景

当遇到以下问题时参考此案例：

1. **npm 包缺少 loong64 支持**
   - 错误：`Unsupported platform: linux-loong64`
   - 解决：添加架构到 `supportedPlatforms`

2. **预编译文件缺失**
   - 错误：`No matching distribution (loong64)`
   - 解决：本地编译 + 修改加载路径

3. **SQLite 扩展符号问题**
   - 错误：`undefined symbol: sqlite3_xxx_init`
   - 解决：使用通用文件名 `vec0.so`

4. **多位置包同步**
   - 问题：修补了一个位置，其他位置仍失败
   - 解决：查找所有位置并同步修改

---

*文档创建时间：2026-03-20*  
*适用架构：loongarch64*  
*相关项目：sqlite-vec, OpenClaw, Node.js*

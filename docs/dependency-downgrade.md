# 依赖版本降级指南

**核心原则：能换依赖就别改代码**

当构建报错提示依赖版本不兼容时，**优先检查系统源是否有兼容版本**，而不是修改源码适配新版本。

---

## 📋 典型案例：OpenStack Dashboard + Django

### 问题现象

```
ImportError: cannot import name 'ugettext_lazy' from 'django.utils.translation'
```

### ❌ 错误做法

```bash
# 试图修改源码适配 Django 4.x
sed -i 's/ugettext_lazy/gettext_lazy/g' *.py
# 问题：修复不完，还有其他 API 变更，维护成本高
```

### ✅ 正确做法（apt 系统）

```bash
# 1. 检查源里是否有兼容版本
apt-cache policy python3-django
# 输出：
# python3-django:
#   已安装：4.2.11
#   候选：4.2.11
#   版本表：
#       4.2.11-1  500
#       3.2.25-1  100  ← 兼容 OpenStack Wallaby

# 2. 卸载新版本，安装兼容版本
sudo apt remove -y python3-django
sudo apt install -y python3-django=3.2.25-1

# 3. 验证版本
python3 -c "import django; print(django.VERSION)"  # 应输出 (3, 2, x)
```

### ✅ 正确做法（yum/dnf 系统）

```bash
# 1. 检查源里是否有兼容版本
yum list --showduplicates python3-django 2>/dev/null | grep python3-django
# 或
dnf list --showduplicates python3-django 2>/dev/null | grep python3-django
# 输出：
# python3-django3.noarch    3.2.25-1    # ← 兼容 OpenStack Wallaby
# python3-django4.noarch    4.2.11-1    # ← 不兼容

# 2. 卸载新版本，安装兼容版本
sudo yum remove -y python3-django4
sudo yum install -y python3-django3

# 3. 验证版本
python3 -c "import django; print(django.VERSION)"  # 应输出 (3, 2, x)

# 4. 重新构建
rpmbuild -ba xxx.spec
```

---

## 🛠️ 通用依赖降级脚本

```bash
#!/bin/bash
# 智能依赖降级脚本 - 自动检测包管理器并降级到兼容版本

# 检测包管理器
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

# 降级依赖（通用）
downgrade_dependency() {
    local pkg=$1
    local compat_version=$2
    local pm=$(detect_pkg_manager)
    
    echo "检查 $pkg 的兼容版本..."
    echo "检测到包管理器：$pm"
    
    case $pm in
        apt)
            # 列出可用版本
            apt-cache policy $pkg | head -10
            
            # 卸载当前版本
            sudo apt remove -y $pkg
            
            # 安装兼容版本（需要指定版本号）
            sudo apt install -y ${pkg}=${compat_version}
            ;;
        yum|dnf)
            # 列出可用版本
            $pm list --showduplicates $pkg 2>/dev/null | grep $pkg
            
            # 卸载当前版本
            sudo $pm remove -y $pkg
            
            # 安装兼容版本
            sudo $pm install -y ${pkg}-${compat_version}
            ;;
    esac
    
    # 验证
    python3 -c "import ${pkg#python3-}; print('OK')" 2>/dev/null || echo "验证跳过"
}

# 使用示例
# downgrade_dependency python3-django 3.2.25
```

---

## 🎯 决策流程

```
构建报错：依赖 X 版本不兼容
    │
    ├─→ 检测包管理器：detect_pkg_manager
    │
    ├─→ 检查源：apt-cache policy / yum list --showduplicates
    │       │
    │       ├─→ 有兼容旧版本 → 卸载新版，安装旧版 ✅
    │       │
    │       └─→ 只有不兼容新版 → 考虑修改源码或找其他源
    │
    └─→ 检查项目文档：确认需要的版本范围
```

---

## 📊 常见版本依赖关系

| 项目 | 需要版本 | apt 包名 | yum/dnf 包名 |
|------|---------|---------|-------------|
| OpenStack Wallaby | Django 3.2.x | python3-django=3.2.x | python3-django3 |
| OpenStack Victoria | Django 3.1.x | python3-django=3.1.x | python3-django3 |
| OpenStack Ussuri | Django 3.0.x | python3-django=3.0.x | python3-django3 |
| Django 4.x 项目 | Django 4.2.x | python3-django=4.2.x | python3-django4 |
| Python 3.6 项目 | Python 3.6 | python3.6 | python3.6 |
| Node 14 项目 | Node.js 14 | nodejs=14.x | nodejs14 |

---

## 📈 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **降级依赖** | ✅ 源码无需修改<br>✅ 官方测试过<br>✅ 后续更新容易 | ⚠️ 需要系统有旧版本 |
| **修改代码** | ✅ 不依赖特定版本 | ❌ 修复不完（API 变更多）<br>❌ 每次构建都要补丁<br>❌ 可能引入新 bug |

---

## 🔗 相关文档

- [../SKILL.md](../SKILL.md) - 主技能文档
- [rust-toolchain.md](rust-toolchain.md) - Rust 工具链版本管理

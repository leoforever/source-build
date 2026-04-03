# 龙芯 pip 源配置

**龙芯 LoongArch 专用 pip 源配置，优先使用龙芯官方源。**

---

## 📦 源配置

### 主源：龙芯官方源
### 备用源：阿里云镜像

---

## 🔧 配置方法

### 临时使用

```bash
pip install -i https://lpypi.loongnix.cn/loongson/pypi \
  --extra-index-url https://mirrors.aliyun.com/pypi/simple \
  package_name
```

### 永久配置

```bash
# 创建配置目录
mkdir -p ~/.pip

# 写入配置
cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://lpypi.loongnix.cn/loongson/pypi
extra-index-url = https://mirrors.aliyun.com/pypi/simple
trusted-host = lpypi.loongnix.cn
              mirrors.aliyun.com
timeout = 60

[install]
trusted-host = lpypi.loongnix.cn
               mirrors.aliyun.com
EOF

# 验证配置
pip config list
```

---

## ❓ 为什么使用双源？

| 源 | 作用 |
|---|------|
| **龙芯官方源** | 针对 loong64 优化的包，优先使用 |
| **阿里云镜像** | 补充龙芯源没有的包，自动降级 |

**优势：**
- ✅ 主源优先使用龙芯官方源（针对 loong64 优化的包）
- ✅ 备用源补充龙芯源没有的包
- ✅ 自动降级，提高成功率

---

## 📋 配置脚本模板

```bash
setup_loongson_pip() {
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://lpypi.loongnix.cn/loongson/pypi
extra-index-url = https://mirrors.aliyun.com/pypi/simple
trusted-host = lpypi.loongnix.cn
              mirrors.aliyun.com
timeout = 60

[install]
trusted-host = lpypi.loongnix.cn
               mirrors.aliyun.com
EOF
    echo "✅ 龙芯 pip 源配置完成"
    pip config list
}

# 使用示例
setup_loongson_pip
```

---

## ✅ 验证配置

```bash
# 查看当前配置
pip config list

# 测试安装
pip install requests -v

# 查看下载源
pip install package_name -i https://lpypi.loongnix.cn/loongson/pypi -v
```

---

## ⚠️ 注意事项

1. **超时设置**：龙芯源可能响应较慢，建议设置 `timeout = 60`

2. **trusted-host**：必须添加，否则可能报 HTTPS 证书错误

3. **系统源优先**：某些包优先使用系统包：
   ```bash
   # 优先系统包
   sudo apt install python3-numpy python3-scipy
   
   # 系统源没有再用 pip
   pip install some-special-package
   ```

---

## 🔗 相关文档

- [python-wheel.md](python-wheel.md) - Python wheel 缺失解决方案
- [../SKILL.md](../SKILL.md) - 主技能文档

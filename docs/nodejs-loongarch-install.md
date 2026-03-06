# 龙芯架构 Node.js 安装指南

> 📌 **适用范围**: loongarch64 架构 (龙芯)
> 
> 📦 **Node.js 版本**: v22.20.0 (非官方构建)

---

## 🚀 快速安装

### 方法 1: 使用安装脚本（推荐）

```bash
~/.openclaw/skills/source-build/scripts/install-node-deps.sh
# 选择 1) 龙芯架构完整安装
```

### 方法 2: 手动安装

```bash
# 1. 下载
cd ~
wget https://unofficial-builds.nodejs.org/download/release/v22.20.0/node-v22.20.0-linux-loong64.tar.gz

# 2. 解压
tar -xzvf node-v22.20.0-linux-loong64.tar.gz

# 3. 配置 PATH
sudo vim /etc/profile
# 最后一行添加：
export PATH=/home/loongson/node-v22.20.0-linux-loong64/bin:$PATH

# 4. 生效
source /etc/profile

# 5. 验证
node --version  # v22.20.0
npm --version
```

---

## 📋 关键信息

| 项目 | 值 |
|------|-----|
| **Node.js 版本** | v22.20.0 |
| **架构** | loong64 |
| **来源** | unofficial-builds.nodejs.org |
| **安装路径** | `/home/loongson/node-v22.20.0-linux-loong64/` |
| **PATH 配置** | `/etc/profile` (全局) |

---

## ✅ 验证安装

```bash
# 检查版本
node --version
npm --version

# 检查 PATH
which node
which npm

# 应该输出：
# /home/loongson/node-v22.20.0-linux-loong64/bin/node
# /home/loongson/node-v22.20.0-linux-loong64/bin/npm
```

---

## ⚠️ 注意事项

1. **需要 root 权限** - 编辑 `/etc/profile` 需要 sudo
2. **非官方构建** - loong64 架构使用非官方构建版本
3. **全局 PATH** - 配置后对所有用户生效
4. **版本更新** - 更新时需要重新下载新版本

---

## 🐛 常见问题

### Q: 下载失败？

**A:** 检查网络连接
```bash
ping unofficial-builds.nodejs.org
```

### Q: `node: command not found`?

**A:** 确认 PATH 已配置并执行了 `source /etc/profile`
```bash
# 检查 PATH
echo $PATH | grep node

# 重新加载
source /etc/profile
```

### Q: 如何卸载？

**A:** 
```bash
# 1. 删除安装目录
rm -rf ~/node-v22.20.0-linux-loong64

# 2. 编辑 /etc/profile 移除 PATH 配置
sudo vim /etc/profile
# 删除：export PATH=...node-v22.20.0-linux-loong64/bin:$PATH

# 3. 重新加载
source /etc/profile
```

### Q: 如何安装多个版本？

**A:** 下载不同版本到不同目录，切换 PATH
```bash
# 安装 v20
wget https://unofficial-builds.nodejs.org/download/release/v20.x.x/node-v20.x.x-linux-loong64.tar.gz
tar -xzvf node-v20.x.x-linux-loong64.tar.gz

# 切换版本（编辑 /etc/profile）
export PATH=/home/loongson/node-v20.x.x-linux-loong64/bin:$PATH
```

---

## 🔧 编译依赖

编译 Node.js 原生模块需要：

```bash
sudo apt install build-essential python3 make
```

---

## 📚 相关文档

- [common-deps.md](common-deps.md) - 常见依赖安装
- [node-notes.md](node-notes.md) - Node.js 编译经验
- [troubleshooting.md](troubleshooting.md) - 问题排查

---

## 📝 更新日志

- **2026-03-06**: 初始版本，包含完整安装步骤和 FAQ

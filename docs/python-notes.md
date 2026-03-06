# Python 编译经验笔记

## 标准编译流程

```bash
# 1. 检查项目结构
ls setup.py pyproject.toml setup.cfg requirements.txt

# 2. 查看依赖
cat requirements.txt

# 3. 安装系统依赖（优先）
sudo apt install python3-dev python3-pip

# 4. 创建虚拟环境（推荐）
python3 -m venv venv
source venv/bin/activate

# 5. 安装依赖
pip install -r requirements.txt

# 6. 安装项目
pip install -e .

# 7. 验证
python -c "import xxx; print(xxx.__version__)"
```

---

## PEP 668 处理（Python 3.12+）

Debian/Ubuntu 的 Python 3.12+ 启用了 PEP 668，阻止系统级 pip 安装。

**三种方案:**

### 方案 1: 虚拟环境（最佳实践）
```bash
python3 -m venv /path/to/venv
source /path/to/venv/bin/activate
pip install -e .
```

### 方案 2: --break-system-packages
```bash
pip install --break-system-packages -e .
```
⚠️ 仅用于测试环境

### 方案 3: pipx（用于应用）
```bash
sudo apt install pipx
pipx install xxx
```

---

## 常见包编译笔记

### cryptography
```bash
# 问题：需要 Rust 编译
# 解决：使用系统包
sudo apt install python3-cryptography libssl-dev
```

### lxml
```bash
# 问题：需要 libxml2/libxslt
# 解决：
sudo apt install libxml2-dev libxslt1-dev python3-lxml
```

### numpy/scipy
```bash
# 问题：需要 BLAS/LAPACK，编译慢
# 解决：使用系统包
sudo apt install python3-numpy python3-scipy libblas-dev liblapack-dev
```

### Pillow
```bash
# 问题：需要图像库
# 解决：
sudo apt install libjpeg-dev zlib1g-dev libtiff-dev libfreetype6-dev
```

### mysqlclient
```bash
# 问题：需要 MySQL 开发库
# 解决：
sudo apt install default-libmysqlclient-dev
```

### psycopg2
```bash
# 问题：需要 PostgreSQL 开发库
# 解决：
sudo apt install libpq-dev
```

---

## 加速编译技巧

### 1. 使用预编译包
```bash
# 先尝试 apt
sudo apt install python3-xxx

# 再 pip 补充
pip install --break-system-packages yyy
```

### 2. 使用 pip 缓存
```bash
pip cache dir  # 查看缓存位置
pip cache info
```

### 3. 并行编译
```bash
# 设置 MAKEFLAGS
export MAKEFLAGS="-j$(nproc)"
```

### 4. 使用镜像源
```bash
# 清华镜像
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple xxx

# 永久配置
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
EOF
```

---

## 调试技巧

### 查看详细编译过程
```bash
pip install -vvv -e . 2>&1 | tee install.log
```

### 查看已安装包
```bash
pip list
pip show package-name
```

### 检查依赖树
```bash
pip install pipdeptree
pipdeptree
```

### 导出依赖
```bash
pip freeze > requirements.txt
```

---

## 龙芯架构注意事项

1. **wheel 包少**: 很多包没有 loong64 预编译，需要源码编译
2. **优先 apt**: loongnix 仓库有一些预编译的 Python 包
3. **Rust 问题**: cryptography 等需要 Rust 的包，优先用 apt 安装
4. **内存**: 编译大型包（如 numpy）需要足够内存

---

## 实用脚本

### 检查 Python 环境
```bash
#!/bin/bash
echo "Python: $(python3 --version)"
echo "pip: $(pip3 --version)"
echo "架构：$(uname -m)"
echo "内存：$(free -h | grep Mem)"
```

### 批量安装依赖
```bash
#!/bin/bash
# install-deps.sh
while read pkg; do
    [[ "$pkg" =~ ^# ]] && continue
    [[ -z "$pkg" ]] && continue
    echo "Installing: $pkg"
    pip install --break-system-packages "$pkg" || apt install -y "python3-$pkg"
done < requirements.txt
```

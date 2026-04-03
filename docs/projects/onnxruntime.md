# onnxruntime LoongArch 编译经验

> 基于 Loongson-Cloud-Community 实际适配经验

---

## 核心问题

1. 需要特定补丁支持
2. 不同 Python 版本适配策略不同
3. 构建时间长，资源消耗大

---

## 多版本 Python 支持

```yaml
python: ["cp311", "cp312", "cp313", "cp313t", "cp314", "cp314t"]
```

**Free-threaded 处理:**
```bash
PYTHON_VERSION="cp313t"
if [[ "$PYTHON_VERSION" == *t ]]; then
    PYTHON_PATH="${PYTHON_VERSION%t}"  # 移除 t 后缀
fi
```

---

## 编译脚本

```bash
#!/bin/bash
set -e

# 1. 下载源码
git clone https://github.com/microsoft/onnxruntime
cd onnxruntime

# 2. 应用 LoongArch 补丁
wget -qO cmake/vcpkg-ports/cpuinfo/cpuinfo_loong64.patch \
    https://raw.githubusercontent.com/Loongson-Cloud-Community/patches/main/cpuinfo_loong64.patch

# 3. 设置构建参数
DEVICE=CPU
BUILD_CONFIG=Release
PYTHON_VERSION=cp312

# 4. Docker 构建（带缓存）
docker run --rm \
    --platform linux/loong64 \
    --volume "$(pwd):/onnxruntime_src" \
    --volume "${HOME}/data/build:/build" \
    -w /onnxruntime_src \
    --env ALLOW_RELEASED_ONNX_OPSET_ONLY=0 \
    ghcr.io/loong64/onnxruntimecpubuildpythonloongarch64:latest \
    /bin/bash -c "
        pip install -r tools/ci_build/github/linux/python/requirements.txt && \
        python3 tools/ci_build/build.py \
            --build_dir build/Release \
            --config Release \
            --cmake_generator Ninja \
            --skip_submodule_sync \
            --skip_tests \
            --build_shared_lib \
            --parallel \
            --use_cache \
            --use_vcpkg \
            --build_wheel && \
        auditwheel repair -w wheelhouse build/Release/Release/dist/*.whl
    "

# 5. 验证
ls -lh wheelhouse/
```

---

## 关键经验

### ✅ 使用构建缓存
```bash
mkdir -p "${HOME}/data/build"
docker run --volume "${HOME}/data/build:/build" ...
```
编译时间从数小时降至数十分钟

### ✅ 支持 free-threaded Python
需要特殊处理 `t` 后缀

### ⚠️ 文件权限问题
容器内用户 ID 不是 1001 时，预创建目录并设置权限：
```bash
mkdir -p wheelhouse build
chmod 777 wheelhouse build
```

---

## 补丁管理

```bash
# 针对不同版本应用不同补丁
case $PYTHON_VERSION in
    3.8*) 
        # 需要更新 config.sub/config.guess
        wget -O config.sub "https://git.savannah.gnu.org/git/config.sub"
        ;;
    3.9*|3.10*|3.11*)
        # 只需要补丁
        curl -sL https://patch-url | patch -p1
        ;;
    *)
        # 3.12+ 通常已原生支持
        ;;
esac
```

---

## 参考资源

- GitHub: Loongson-Cloud-Community/onnxruntime
- Docker: ghcr.io/loong64/onnxruntimecpubuildpythonloongarch64:latest

# Go 编译配置（龙芯 loong64）

**在龙芯 LoongArch 平台编译 Go 项目时，必须配置 GOPROXY 并使用正确的 Go 版本。**

---

## 🔧 核心配置

```bash
# Go 模块代理（中国大陆加速）
export GOPROXY=https://goproxy.cn,direct

# 强制使用系统 Go（避免版本冲突）
export FORCE_HOST_GO=true

# 目标平台
export GOOS=linux
export GOARCH=loong64
```

---

## 📦 Go 版本安装（loong64 架构）

Go 官方从 **1.19** 版本开始支持 loong64 架构。

### 安装步骤

```bash
# Go 1.26.1 示例（替换版本号即可）
wget https://go.dev/dl/go1.26.1.linux-loong64.tar.gz

# 解压到 /usr/local
sudo tar -C /usr/local -xzf go1.26.1.linux-loong64.tar.gz

# 添加到 PATH
export PATH=/usr/local/go/bin:$PATH

# 验证安装
go version
# 应输出：go version go1.26.1 linux/loong64
```

### 常用版本下载链接

| 版本 | 下载链接 |
|------|---------|
| 1.26.1 | https://go.dev/dl/go1.26.1.linux-loong64.tar.gz |
| 1.25.0 | https://go.dev/dl/go1.25.0.linux-loong64.tar.gz |
| 1.24.0 | https://go.dev/dl/go1.24.0.linux-loong64.tar.gz |
| 1.23.0 | https://go.dev/dl/go1.23.0.linux-loong64.tar.gz |
| 1.22.0 | https://go.dev/dl/go1.22.0.linux-loong64.tar.gz |
| 1.21.0 | https://go.dev/dl/go1.21.0.linux-loong64.tar.gz |
| 1.20.0 | https://go.dev/dl/go1.20.0.linux-loong64.tar.gz |
| 1.19.0 | https://go.dev/dl/go1.19.0.linux-loong64.tar.gz |

**注意：** 低于 1.19 的版本不支持 loong64 架构。

---

## 💡 Kubernetes 编译示例

```bash
# Kubernetes 编译环境变量
export GOPROXY=https://goproxy.cn,direct
export FORCE_HOST_GO=true
export KUBE_BUILD_CONFORMANCE=n
export KUBE_RELEASE_RUN_TESTS=n
export KUBE_BUILD_PLATFORMS=linux/loong64
export KUBE_BASE_IMAGE_REGISTRY=lcr.loongnix.cn/kubernetes-build-image

# 执行编译
make quick-release 2>&1 | tee /tmp/k8s-build-$(date +%Y%m%d-%H%M%S).log
```

---

## 📋 通用 Go 项目编译脚本

```bash
#!/bin/bash
# Go 项目编译脚本（龙芯 loong64）
set -e

LOGFILE="/tmp/go-build-$(date +%Y%m%d-%H%M%S).log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a $LOGFILE; }
log_cmd() {
    log "【命令】$*"
    "$@" 2>&1 | tee -a $LOGFILE
    local status=$?
    log "【状态】$([ $status -eq 0 ] && echo '✅ 成功' || echo "❌ 失败 (exit code: $status)")"
    return $status
}

log "========================================"
log "  Go 编译开始 (loong64)"
log "========================================"

# 检查 Go 版本
log_step "环境检查"
log_cmd go version

# 配置 GOPROXY
log_step "配置 Go 模块代理"
export GOPROXY=https://goproxy.cn,direct
log "GOPROXY=$GOPROXY"

# 设置目标平台
log_step "设置目标平台"
export GOOS=linux
export GOARCH=loong64
log "GOOS=$GOOS, GOARCH=$GOARCH"

# 执行编译
log_step "执行编译"
log_cmd go build -v -o output ./...

# 检查产物
log_step "检查编译产物"
log_cmd ls -lh output
log_cmd file output

log "========================================"
log "  编译完成"
log "========================================"
log "日志文件：$LOGFILE"
```

---

## 🎯 决策流程

```
Go 编译问题
    │
    ├─→ 下载依赖慢/失败 → 配置 GOPROXY=https://goproxy.cn,direct ✅
    │
    ├─→ 架构不支持 → 检查 Go 版本 >= 1.19 ✅
    │
    ├─→ 版本不匹配 → 下载对应 loong64 版本 ✅
    │
    └─→ 编译失败 → 检查 CGO 依赖（gcc、glibc-dev）✅
```

---

## ❗ 常见问题

| 问题 | 错误信息 | 解决方案 |
|------|---------|---------|
| 依赖下载慢 | `dial tcp: lookup proxy.golang.org: no such host` | 配置 `GOPROXY=https://goproxy.cn,direct` |
| 架构不支持 | `unsupported goos/goarch` | 升级 Go >= 1.19 |
| CGO 编译失败 | `gcc: error: unrecognized command-line option` | 安装 `gcc` 和 `glibc-devel` |
| 版本不匹配 | `go.mod requires go 1.26` | 下载对应版本 `go1.26.1.linux-loong64.tar.gz` |

---

## 🔧 CGO 依赖安装

```bash
# Debian/Loongnix
sudo apt install gcc libc6-dev

# RHEL/CentOS/openEuler
sudo yum install gcc glibc-devel
```

---

## 🔗 静态链接编译

### Go 项目完全静态链接

```bash
# 设置静态链接标志
export CGO_ENABLED=1
export CGO_LDFLAGS="-static -static-libgcc -static-libstdc++"

# 编译
go build -ldflags="-w -s" -o myapp-static .

# 验证
file myapp-static | grep "statically linked"
ldd myapp-static 2>&1 | grep "not a dynamic"
```

### 注意事项

1. **需要静态库依赖**
   ```bash
   # openEuler/Loongnix
   dnf install -y libstdc++-static glibc-static
   ```

2. **glibc 静态链接警告**
   ```
   Using 'dlopen'/'getaddrinfo' in statically linked applications requires at runtime 
   the shared libraries from the glibc version used for linking
   ```
   - 这是标准警告，不影响功能
   - 避免在静态链接程序中使用 NSS 相关功能

3. **链接第三方静态库**
   ```bash
   export CGO_LDFLAGS="-static -L/path/to/libs -lmylib -lggml-cpu -lggml-base"
   ```

### 案例：Ollama 静态编译

参考：[docs/case-ollama-loongarch.md](docs/case-ollama-loongarch.md)

```bash
# Ollama 静态编译关键配置
export CGO_ENABLED=1
export CGO_CFLAGS="-I/tmp/ollama/build/include"
export CGO_LDFLAGS="-static -L/tmp/ollama/build/ml/backend/ggml/ggml/src -lggml-cpu -lggml-base -static-libgcc -static-libstdc++"

/usr/local/go/bin/go build \
    -ldflags="-w -s \"-X=github.com/ollama/ollama/version.Version=$VERSION\"" \
    -o ollama-static .
```

---

## 🔗 相关文档

- [../SKILL.md](../SKILL.md) - 主技能文档
- [rust-toolchain.md](rust-toolchain.md) - Rust 工具链版本管理

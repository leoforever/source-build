# 常见编译配置片段

## Python 虚拟环境
```bash
python3 -m venv venv
source venv/bin/activate
```

## Rust 镜像
```bash
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
```

## CMake 标准流程
```bash
mkdir build && cd build
cmake .. && make -j$(nproc)
```

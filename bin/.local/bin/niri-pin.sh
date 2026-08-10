#!/bin/bash

# 1. 准备环境
TMP_DIR="/tmp/niri_pinned"
mkdir -p "$TMP_DIR"

# 检查依赖
for cmd in slurp grim imv; do
  if ! command -v $cmd &>/dev/null; then
    notify-send "错误" "缺少依赖: $cmd"
    exit 1
  fi
done

# 2. 获取截图区域信息
# GEOM 格式为 "x,y wxh"
GEOM=$(slurp -d)
[ -z "$GEOM" ] && exit 0

# 提取宽度和高度用于设置窗口
# 使用 python3 快速解析字符串（因为 shell 解析这种格式略显繁琐）
WIDTH=$(echo "$GEOM" | python3 -c "import sys; print(sys.stdin.read().split(' ')[1].split('x')[0])")
HEIGHT=$(echo "$GEOM" | python3 -c "import sys; print(sys.stdin.read().split(' ')[1].split('x')[1])")

# 3. 生成唯一文件名
FILENAME="$TMP_DIR/pin_$(date +%s%N).png"

# 4. 截图并精确启动 imv
# -W, -H: 设置初始窗口大小
# -i: 设置 App ID 供 niri 匹配
# -s full: 让图片填满窗口
grim -g "$GEOM" "$FILENAME" &&
  imv -i "pin-screenshot" -W "$WIDTH" -H "$HEIGHT" -s full -x "$FILENAME" &

#!/bin/bash

# 定义临时文件和 PID 路径
PID_FILE="/tmp/niri_recorder.pid"
TMP_VIDEO="/tmp/recording_$(date +%s).mp4"
VIDEO_PATH_FILE="/tmp/niri_recording_path.txt"
TARGET_DIR="$HOME/Pictures/gif"
TARGET="$TARGET_DIR/Recording_$(date +%Y-%m-%d_%H-%M-%S).gif"

# 检查依赖 (增加了 python3 用于处理路径编码，大部分 Linux 默认都有)
for cmd in slurp wf-recorder ffmpeg notify-send wl-copy python3; do
  if ! command -v $cmd &>/dev/null; then
    notify-send "错误" "缺少依赖: $cmd"
    exit 1
  fi
done

# --- 逻辑判断：是开始还是结束 ---

if [ -f "$PID_FILE" ]; then
  # 【结束录制逻辑】
  PID=$(cat "$PID_FILE")

  if [ -f "$VIDEO_PATH_FILE" ]; then
    RECORDING_VIDEO=$(cat "$VIDEO_PATH_FILE")
  else
    notify-send "错误" "找不到录制文件路径"
    rm "$PID_FILE"
    exit 1
  fi

  # 停止 wf-recorder 并等待完全退出
  kill "$PID"
  while kill -0 "$PID" 2>/dev/null; do sleep 0.1; done

  rm "$PID_FILE"
  rm "$VIDEO_PATH_FILE"

  notify-send "录制" "正在转换高质量 GIF..."

  # 转换为 GIF (保持画质优化)
  ffmpeg -i "$RECORDING_VIDEO" -vf \
    "fps=15,scale='min(800,iw)':-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
    "$TARGET" -y -loglevel error

  if [ -f "$TARGET" ]; then
    # 获取绝对路径
    ABS_TARGET=$(realpath "$TARGET")

    # 【核心修改】
    # 使用 Python 生成标准的 file:// URI 路径
    # 这样可以处理文件名中可能出现的空格或特殊字符
    URI=$(python3 -c "import urllib.parse; print('file://' + urllib.parse.quote('$ABS_TARGET'))")

    # 只写入 text/uri-list
    # 这样 Discord/Twitter 会把它当作“文件上传”处理，从而保留 GIF 动画
    echo -n "$URI" | wl-copy --type text/uri-list

    notify-send "录制成功" "动图文件已复制 (文件模式)\n$TARGET"
    rm "$RECORDING_VIDEO"
  else
    notify-send "录制失败" "FFmpeg 转换出现问题"
  fi

else
  # 【开始录制逻辑】
  if GEOM=$(slurp); then
    echo "$TMP_VIDEO" >"$VIDEO_PATH_FILE"
    wf-recorder -g "$GEOM" -f "$TMP_VIDEO" &
    echo $! >"$PID_FILE"
    notify-send "录制" "录制已开始..."
  else
    exit 1
  fi
fi

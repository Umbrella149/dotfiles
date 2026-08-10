#!/bin/bash
TARGET="$HOME/Pictures/Recording_$(date +%Y-%m-%d_%H-%M-%S).gif"
TMP_VIDEO="/tmp/recording.mp4"

# 1. 选择区域并录制 (增加退出处理)
GEOM=$(slurp) || exit 1
notify-send "录制" "正在录制选定区域..."
wf-recorder -g "$GEOM" -f "$TMP_VIDEO"

# 2. 转换为高质量 GIF
notify-send "录制" "正在转换 GIF，请稍候..."
ffmpeg -i "$TMP_VIDEO" -vf "fps=15,scale='min(1200,iw)':-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$TARGET"

# 3. 完成通知
notify-send "录制成功" "动图已保存至: $TARGET"
rm "$TMP_VIDEO"

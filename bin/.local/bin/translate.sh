#!/bin/bash

# 配置文件路径
WORD_FILE="$HOME/words.txt"

# 获取剪切板内容并修剪空格
text=$(wl-paste | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$text" ]; then
  notify-send "翻译助手" "剪切板为空"
  exit 1
fi

# 1. 执行翻译 (使用 brief 模式)
result=$(trans -b :zh "$text" 2>/dev/null)

if [ -z "$result" ]; then
  notify-send "翻译助手" "翻译失败，请检查网络"
  exit 1
fi

# 2. 发送通知
notify-send -i accessories-dictionary -a "Translate" "$text" "$result"

# 3. 统计词频逻辑
# 只有当 text 是单个单词（不包含空格）时才进行统计
if [[ ! "$text" =~ [[:space:]] ]]; then
  # 转为小写处理，避免重复统计 (Apple 和 apple 视为同一个)
  word=$(echo "$text" | tr '[:upper:]' '[:lower:]' | sed 's/[[:punct:]]//g')

  if [ ! -f "$WORD_FILE" ]; then
    touch "$WORD_FILE"
  fi

  # 检查单词是否已在文件中
  if grep -qP "^${word}\t" "$WORD_FILE"; then
    # 如果存在：利用 awk 找到该行，将第二列数字加 1
    # 这种方式比 sed 替换更安全可靠
    awk -F'\t' -v w="$word" 'BEGIN{OFS="\t"} $1==w {$2=$2+1} {print}' "$WORD_FILE" >"${WORD_FILE}.tmp" && mv "${WORD_FILE}.tmp" "$WORD_FILE"
  else
    # 如果不存在：追加新行，计数初始化为 1
    printf "%s\t%d\n" "$word" 1 >>"$WORD_FILE"
  fi
fi

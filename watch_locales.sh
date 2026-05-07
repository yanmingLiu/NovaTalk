#!/bin/bash

# 加入全局 pub-cache bin 到 PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

LOCALE_DIR="./library/language"
LAST_MOD=0

echo "🔍 轮询监听 $LOCALE_DIR/*.json ..."

while true; do
  FILES=("$LOCALE_DIR"/*.json)
  if [ -e "${FILES[0]}" ]; then
    NEW_MOD=$(stat -f "%m" "${FILES[@]}" | sort -nr | head -n1)
    if [ "$NEW_MOD" -ne "$LAST_MOD" ]; then
      echo "📌 JSON 文件变化，执行 generate..."
      get generate locales "$LOCALE_DIR"
      LAST_MOD=$NEW_MOD
    fi
  fi
  sleep 2
done

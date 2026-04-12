#!/bin/bash

URL="$1"
OUT_DIR="$HOME/Music/rmpc"
mkdir -p "$OUT_DIR"

[[ -z "$URL" ]] && exit 1

# NON-BLOCKING download only
yt-dlp \
  --no-playlist \
  --retries 1 \
  --fragment-retries 1 \
  --socket-timeout 10 \
  --force-ipv4 \
  -f "bv*[height<=720][ext=mp4]+ba[ext=m4a]/b" \
  -o "$OUT_DIR/%(title).80s.%(ext)s" \
  "$URL" &

exit 0

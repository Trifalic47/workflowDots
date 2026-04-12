#!/bin/bash

URL="$1"
[[ -z "$URL" ]] && exit 0

exec mpv \
    --no-terminal \
    --force-window=yes \
    --vo=gpu-next \
    --gpu-api=vulkan \
    --hwdec=auto-safe \
    --cache=yes \
    --cache-secs=2 \
    --demuxer-readahead-secs=2 \
    --ytdl-format="bv*[height<=720][vcodec!=av01]+ba/b[height<=720]" \
    "$URL"

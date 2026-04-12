#!/bin/bash
# ─────────────────────────────────────────────
#  search_yt.sh — Fast YouTube search for rmpc
#  v3 — optimized for Intel Haswell GPU
# ─────────────────────────────────────────────

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rmpc_yt"
mkdir -p "$CACHE_DIR"

CURRENT_URL_FILE="/tmp/rmpc_current_yt_url"
LOG_FILE="/tmp/rmpc_yt.log"

# ── 1. Get search query ───────────────────────
QUERY=$(rofi -dmenu \
    -p "󰗃  Search YouTube" \
    -theme-str '
        window   { width: 42%; border-radius: 12px; }
        inputbar { padding: 10px; }
        listview { lines: 0; }
    ')
[[ -z "$QUERY" ]] && exit 0

# ── 2. Cache key based on query ───────────────
CACHE_KEY=$(echo "$QUERY" | md5sum | cut -d' ' -f1)
CACHE_FILE="$CACHE_DIR/${CACHE_KEY}.cache"

# Use cache if less than 10 minutes old
if [[ -f "$CACHE_FILE" ]] && \
   [[ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt 600 ]]; then
    RESULTS=$(cat "$CACHE_FILE")
else
    RESULTS=$(yt-dlp \
        "ytsearch30:$QUERY" \
        --flat-playlist \
        --quiet \
        --no-warnings \
        --no-check-certificates \
        --extractor-args "youtube:skip=dash,hls" \
        --print "%(duration_string)s 󰇙 %(title)s 󰇙 %(uploader)s 󰇙 ID:%(id)s" \
        2>/dev/null)
    echo "$RESULTS" > "$CACHE_FILE"
fi

[[ -z "$RESULTS" ]] && {
    notify-send "󰗃 YouTube" "No results found for: $QUERY" -u normal
    exit 1
}

# ── 3. Show results in rofi ───────────────────
SELECTED=$(echo "$RESULTS" | rofi -dmenu -i \
    -p "󰗃  Select" \
    -theme-str '
        window      { width: 65%; max-height: 88%; border-radius: 12px; }
        listview    { scrollbar: true; lines: 14; spacing: 4px; }
        element     { padding: 8px 10px; border-radius: 6px; }
        element-text{ font: "JetBrainsMono Nerd Font 10"; }
    ')
[[ -z "$SELECTED" ]] && exit 0

# ── 4. Parse selection ────────────────────────
VIDEO_ID=$(echo "$SELECTED" | grep -oP 'ID:\K[a-zA-Z0-9_-]+')
TITLE=$(echo "$SELECTED" | awk -F ' 󰇙 ' '{print $2}')
URL="https://www.youtube.com/watch?v=$VIDEO_ID"

[[ -z "$VIDEO_ID" ]] && {
    notify-send "󰅙 Error" "Could not parse video ID" -u critical
    exit 1
}

echo "$(date): Selected [$TITLE] $URL" >> "$LOG_FILE"
notify-send "󰐊 Loading" "$TITLE" -t 2000

# ── 5. Launch mpv instantly ───────────────────
# Haswell-specific flags:
# --vo=gpu          → use stable OpenGL backend, NOT gpu-next (Vulkan incomplete on Haswell)
# --hwdec=vaapi     → Intel VA-API is the correct decoder for Haswell, not VDPAU/CUDA
# --gpu-api=opengl  → force OpenGL, skip Vulkan entirely (avoids 2min Vulkan init delay)
# --no-vulkan       → explicitly disable Vulkan probing
/usr/bin/mpv \
    --force-window=yes \
    --ontop \
    --no-terminal \
    --geometry=854x480-20-20 \
    --title="󰗃 $TITLE" \
    --cache=yes \
    --cache-secs=10 \
    --demuxer-max-bytes=50MiB \
    --vo=gpu \
    --gpu-api=opengl \
    --hwdec=vaapi \
    --ytdl=yes \
    --ytdl-format="bestvideo[height<=480]+bestaudio/best" \
    --ytdl-raw-options="no-check-certificates=,extractor-args=youtube:skip=dash" \
    "$URL" >> "$LOG_FILE" 2>&1 &

MPV_PID=$!
echo "$MPV_PID" > /tmp/rmpc_mpv_pid
echo "$(date): mpv launched PID=$MPV_PID" >> "$LOG_FILE"

notify-send "󰗃 Playing" "$TITLE" -t 3000

# ── 6. Sync audio to mpd in background ────────
(
    sleep 1
    AUDIO_URL=$(yt-dlp \
        --no-check-certificates \
        --no-warnings \
        --extractor-args "youtube:skip=dash,hls" \
        -f "bestaudio" \
        --get-url \
        "$URL" 2>/dev/null)

    if [[ -n "$AUDIO_URL" ]]; then
        mpc stop   2>/dev/null
        mpc clear  2>/dev/null
        mpc add    "$AUDIO_URL" 2>/dev/null
        mpc play   2>/dev/null
        mpc volume 0 2>/dev/null  # muted — mpv handles audio
        echo "$URL" > "$CURRENT_URL_FILE"
        echo "$(date): mpd synced OK" >> "$LOG_FILE"
    else
        echo "$(date): mpd audio fetch failed" >> "$LOG_FILE"
    fi
) &

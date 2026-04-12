#!/bin/bash
# ─────────────────────────────────────────────
#  play_video.sh — Sync local video with rmpc
#  Called via 'V' keybind inside rmpc
# ─────────────────────────────────────────────

MUSIC_DIR="/home/tanishq/Music"
LOG_FILE="/tmp/rmpc_video.log"
MPV_PID_FILE="/tmp/rmpc_mpv_pid"

echo "$(date): play_video.sh triggered" >> "$LOG_FILE"

# ── 1. Get current song path ──────────────────
# Prefer env var set by rmpc (instant), fall back to parsing rmpc song
if [[ -n "$FILE" ]]; then
    SONG_PATH="$FILE"
else
    SONG_PATH=$(rmpc song 2>/dev/null | grep -Po '"file":"\K[^"]+')
fi

if [[ -z "$SONG_PATH" ]]; then
    notify-send "󰅙 No Song" "Nothing is currently playing in rmpc." -u low
    exit 0
fi

echo "Song path: $SONG_PATH" >> "$LOG_FILE"

# ── 2. Get current playback position ─────────
ELAPSED=$(rmpc status 2>/dev/null | grep -Po '"elapsed":\{"secs":\K[0-9]+')
[[ -z "$ELAPSED" || "$ELAPSED" == "null" ]] && ELAPSED=0
echo "Elapsed: ${ELAPSED}s" >> "$LOG_FILE"

FULL_PATH="$MUSIC_DIR/$SONG_PATH"

# ── 3. Kill any existing mpv instance ─────────
if [[ -f "$MPV_PID_FILE" ]]; then
    OLD_PID=$(cat "$MPV_PID_FILE")
    kill "$OLD_PID" 2>/dev/null
    rm -f "$MPV_PID_FILE"
fi

# ── 4. Handle different file types ───────────
if [[ "$FULL_PATH" =~ \.(mp4|mkv|webm|avi|mov)$ ]]; then
    # ── Local video file ──────────────────────
    rmpc pause 2>/dev/null

    /usr/bin/mpv \
        --profile=fast \
        --no-ytdl \
        --vo=gpu-next \
        --hwdec=auto \
        --start="${ELAPSED}" \
        --force-window=yes \
        --ontop \
        --no-terminal \
        --geometry=854x480-20-20 \
        --title="󰐊 $(basename "$FULL_PATH")" \
        "$FULL_PATH" >> "$LOG_FILE" 2>&1 &

    echo $! > "$MPV_PID_FILE"
    notify-send "󰐊 Video" "Playing: $(basename "$FULL_PATH") at ${ELAPSED}s" -t 3000

elif [[ "$SONG_PATH" =~ ^https?:// ]]; then
    # ── Stream URL (YouTube added via search_yt.sh) ──
    rmpc pause 2>/dev/null

    /usr/bin/mpv \
        --vo=gpu-next \
        --hwdec=auto \
        --force-window=yes \
        --ontop \
        --no-terminal \
        --geometry=854x480-20-20 \
        --cache=yes \
        --cache-secs=10 \
        --start="${ELAPSED}" \
        --title="󰗃 Stream" \
        --ytdl-format="bestvideo[height<=720]+bestaudio/best" \
        "$SONG_PATH" >> "$LOG_FILE" 2>&1 &

    echo $! > "$MPV_PID_FILE"
    notify-send "󰗃 Stream" "Opening video stream at ${ELAPSED}s" -t 3000

else
    # ── Audio only ────────────────────────────
    notify-send "󰈑 Audio Only" \
        "$(basename "$SONG_PATH") has no video.\nPress 'S' to search YouTube." \
        -u low -t 4000
fi

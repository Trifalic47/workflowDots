#!/bin/bash
# Universal Video Toggle Script for rmpc
# Supports both Local Files (.mp4) and YouTube Cache Files

MUSIC_DIR="/home/tanishq/Music"
CACHE_DIR="/home/tanishq/.cache/rmpc/youtube"
LOG_FILE="/tmp/rmpc_video.log"

# 1. Get current track path and elapsed time
# The environment variable $FILE is provided by rmpc's ExternalCommand
SONG_PATH="${FILE:-$(rmpc song | grep -Po '"file":"\K[^"]+')}"
SECONDS=$(rmpc status | grep -Po 'elapsed: [^,]+' | cut -d' ' -f2 | tr -d '[:space:]')

# Handle empty or null seconds
if [[ -z "$SECONDS" || "$SECONDS" == "null" ]]; then SECONDS="0"; fi

echo "Toggling: $SONG_PATH at ${SECONDS}s" > "$LOG_FILE"

if [[ -z "$SONG_PATH" ]]; then
    exit 0
fi

# 2. Identify the full path (check Music dir first, then cache)
if [[ -f "$MUSIC_DIR/$SONG_PATH" ]]; then
    FULL_PATH="$MUSIC_DIR/$SONG_PATH"
elif [[ -f "$CACHE_DIR/$SONG_PATH" ]]; then
    FULL_PATH="$CACHE_DIR/$SONG_PATH"
else
    # Some rmpc versions might store it in a nested cache folder
    FULL_PATH=$(find "$CACHE_DIR" -name "$(basename "$SONG_PATH")" | head -n 1)
fi

# 3. Play if it's a video file
if [[ "$FULL_PATH" == *.mp4 || "$FULL_PATH" == *.opus || "$FULL_PATH" == *.webm ]]; then
    rmpc pause
    notify-send "󰐊 Video Toggle" "Opening video at ${SECONDS}s..." -t 2000 -i video-x-generic
    
    # Launch mpv with the exact same timestamp
    /usr/bin/mpv --start="${SECONDS}" --force-window=yes --ontop --geometry=600x400-20-20 "$FULL_PATH" >> "$LOG_FILE" 2>&1 &
else
    notify-send "󰈑 Audio Only" "No video source found for this track." -u low
fi

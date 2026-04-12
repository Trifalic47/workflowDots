#!/bin/bash
MUSIC_DIR="/home/tanishq/Music"
LOG_FILE="/tmp/rmpc_video.log"

# 1. Use environment variables provided by rmpc if available
# Otherwise parse the JSON from 'rmpc song'
if [[ -n "$FILE" ]]; then
    SONG_PATH="$FILE"
else
    SONG_PATH=$(rmpc song | grep -Po '"file":"\K[^"]+')
fi

# 2. Get elapsed time from rmpc status
# The output format is like: Status(state: Playing, volume: 100, repeat: false, ..., elapsed: 12.34, ...)
SECONDS=$(rmpc status | grep -Po 'elapsed: [^,]+' | cut -d' ' -f2)

# Fallback for SECONDS if rmpc status is weird
if [[ -z "$SECONDS" || "$SECONDS" == "null" ]]; then
    SECONDS=$(mpc -f %elapsed% current | awk -F: '{ if (NF==3) print ($1*3600 + $2*60 + $3); else if (NF==2) print ($1*60 + $2); else print $1 }')
fi

echo "Playing: $SONG_PATH at ${SECONDS:-0}s" > "$LOG_FILE"

if [[ -z "$SONG_PATH" ]]; then
    echo "Error: Could not determine SONG_PATH" >> "$LOG_FILE"
    exit 0
fi

FULL_PATH="$MUSIC_DIR/$SONG_PATH"
echo "Full path: $FULL_PATH" >> "$LOG_FILE"

if [[ "$FULL_PATH" == *.mp4 ]]; then
    # 3. Pause playback
    rmpc pause
    
    # 4. Open mpv in the background
    # Use -nogui if you want it faster, or just standard mpv
    echo "Executing: /usr/bin/mpv --start=${SECONDS:-0} --force-window=yes --ontop \"$FULL_PATH\"" >> "$LOG_FILE"
    /usr/bin/mpv --start="${SECONDS:-0}" --force-window=yes --ontop --geometry=600x400-20-20 "$FULL_PATH" >> "$LOG_FILE" 2>&1 &
    
    notify-send "󰐊 Video Sync" "Starting at ${SECONDS:-0}s..." -i video-x-generic
else
    echo "Error: Not an mp4 file" >> "$LOG_FILE"
    notify-send "󰈑 Audio Only" "No video file found." -u low
fi

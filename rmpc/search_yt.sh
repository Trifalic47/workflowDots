#!/bin/bash
# High-Speed YouTube Streamer (Zero-Download / No-Wait)

# 1. Ask for query
QUERY=$(rofi -dmenu -p "󰗃 SEARCH" -theme-str 'window {width: 40%;} listview {lines: 0;}')
[[ -z "$QUERY" ]] && exit 0

# 2. Fast-Fetch results
# --flat-playlist is essential for speed
RAW_DATA=$(yt-dlp "ytsearch10:$QUERY" --flat-playlist --print "%(title)s|%(id)s" --no-warnings 2>/dev/null)

if [[ -z "$RAW_DATA" ]]; then
    notify-send "󰈑 Error" "No results found." -u critical
    exit 1
fi

# 3. Selection Menu
SELECTED=$(echo "$RAW_DATA" | sed 's/|/  󰇙  ID:/' | rofi -dmenu -p "󰗃 Select Video" -i -l 10 -theme-str 'window {width: 60%;}')

if [[ -n "$SELECTED" ]]; then
    VIDEO_ID=$(echo "$SELECTED" | awk -F '  󰇙  ID:' '{print $NF}')
    TITLE=$(echo "$SELECTED" | awk -F '  󰇙  ID:' '{print $1}')
    URL="https://www.youtube.com/watch?v=$VIDEO_ID"

    notify-send "󰐊 LIVE STREAM" "$TITLE" -t 2000

    # 4. INSTANT AUDIO (Direct Stream URL)
    # We get the direct audio stream URL and add it to mpc
    # This is 100x faster because MPD can play direct streams instantly
    (
        STREAM_URL=$(yt-dlp -g -f "bestaudio" "$URL" 2>/dev/null)
        if [[ -n "$STREAM_URL" ]]; then
            mpc add "$STREAM_URL"
            # Jump to the newly added stream and play it
            mpc play $(mpc playlist | wc -l)
        fi
    ) >/dev/null 2>&1 &
    
    # 5. INSTANT VIDEO (Standalone mpv)
    # Optimized for fast buffering and normal window mode
    /usr/bin/mpv --force-window=yes \
        --ontop \
        --no-terminal \
        --geometry=700x400-20-20 \
        --title="LIVE: $TITLE" \
        --ytdl-format="bestvideo[height<=720]+bestaudio/best" \
        --cache=yes --demuxer-readahead-secs=5 \
        "$URL" >/dev/null 2>&1 &
fi

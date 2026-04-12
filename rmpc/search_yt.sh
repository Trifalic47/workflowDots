#!/bin/bash

QUERY=$(rofi -dmenu -p "󰗃 Search YouTube")
[[ -z "$QUERY" ]] && exit 0

RESULTS=$(yt-dlp \
    --quiet \
    --flat-playlist \
    "ytsearch10:$QUERY" \
    --print "%(title)s 󰇙 ID:%(id)s")

SELECTED=$(echo "$RESULTS" | rofi -dmenu -i -p "Select")
[[ -z "$SELECTED" ]] && exit 0

VIDEO_ID=$(echo "$SELECTED" | grep -oP 'ID:\K[^ ]+')

exec ~/.config/rmpc/play_video.sh "https://www.youtube.com/watch?v=$VIDEO_ID"

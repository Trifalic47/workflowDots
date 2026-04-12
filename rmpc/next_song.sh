#!/bin/bash

HIST="$HOME/.local/share/rmpc/history.tsv"

[[ ! -f "$HIST" ]] && exit 0

# simple "taste model"
# pick random from last 30 plays (you like repetition → this simulates preference)
URL=$(tail -n 30 "$HIST" | shuf | cut -f2 | head -n1)

echo "$URL"

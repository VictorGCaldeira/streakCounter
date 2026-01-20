#!/bin/bash

USERNAME=$1
FILE_PATH="streakData/${USERNAME}.json"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

# Extract Data
STREAK=$(jq -r '.streakCount' "$FILE_PATH")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$FILE_PATH")
MAX_STREAK=$(jq -r '.maxStreak' "$FILE_PATH")
START_DATE="Jan 10, 2017" 
TODAY=$(date +"%b %d")

# Styling
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"
OUTPUT="badges/${USERNAME}_badge.png"

mkdir -p badges

# Generate Badge (No comments allowed inside this multiline command)
convert -size 650x250 xc:"$BG_COLOR" \
    -fill "$TEXT_COLOR" -font "DejaVu-Sans" \
    -gravity West -pointsize 45 -draw "text 60,-20 '$TOTAL_CONTRIB'" \
    -fill "$TEXT_COLOR" -pointsize 18 -draw "text 55,25 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 60,60 '$START_DATE - Present'" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 -draw "line 215,50 215,200" \
    -draw "line 435,50 435,200" \
    -stroke none -gravity Center \
    -fill none -stroke "$ORANGE" -strokewidth 5 -draw "arc 265,40 385,160 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 325,30 Q 315,50 325,65 Q 335,50 325,30 Z'" \
    -fill "$TEXT_COLOR" -pointsize 45 -draw "text 0,-15 '$STREAK'" \
    -fill "$ORANGE" -pointsize 18 -draw "text 0,55 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 0,85 '$TODAY - Present'" \
    -gravity East -fill "$TEXT_COLOR" -pointsize 45 -draw "text 80,-20 '$MAX_STREAK'" \
    -pointsize 18 -draw "text 65,25 'Longest Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 50,60 'All-time High'" \
    "$OUTPUT"

echo "Success: Badge generated at $OUTPUT"

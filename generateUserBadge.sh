#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Data Extraction & Date Formatting
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_MAX_STREAK_DATE=$(jq -r '.maxStreakDate' "$STREAK_FILE")

START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")
[ "$RAW_MAX_STREAK_DATE" != "null" ] && MAX_STREAK_DISPLAY=$(date -d "$RAW_MAX_STREAK_DATE" +"%b %d, %Y") || MAX_STREAK_DISPLAY="N/A"

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 2. Styling
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Auto-detect font
MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 3. Generate Badge
# We use -annotate instead of -draw "text" to fix the "non-conforming" error
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "$MY_FONT" -fill "$TEXT_COLOR" \
    -gravity West -pointsize 52 -annotate +80-20 "$TOTAL_CONTRIB" \
    -fill "$TEXT_COLOR" -pointsize 18 -annotate +75+25 "Total Contributions" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate +80+60 "$START_DATE - Present" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 280,40 280,210" -draw "line 570,40 570,210" \
    -stroke none -fill none -stroke "$ORANGE" -strokewidth 5 \
    -draw "arc 370,45 480,155 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,35 Q 415,50 425,65 Q 435,50 425,35 Z'" \
    -fill "$ORANGE" -pointsize 18 -gravity North -annotate +0+165 "Current Streak" \
    -fill "$SUB_TEXT" -pointsize 14 -gravity North -annotate +0+195 "$MAX_STREAK_DISPLAY - Present" \
    -fill "$TEXT_COLOR" -pointsize 52 -gravity North -annotate +0+75 "$STREAK" \
    -stroke none -fill "$TEXT_COLOR" -gravity East \
    -pointsize 52 -annotate +100-20 "$MAX_STREAK" \
    -pointsize 18 -annotate +85+25 "Longest Streak" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate +70+60 "All-time High" \
    "$OUTPUT"

echo

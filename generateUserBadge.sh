#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Data Extraction
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_CURRENT_STREAK_DATE=$(jq -r '.currentStreakDate' "$STREAK_FILE")

[[ "$RAW_CREATED_AT" != "null" ]] && START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y") || START_DATE="N/A"
[[ "$RAW_CURRENT_STREAK_DATE" != "null" ]] && CURRENT_STREAK_DISPLAY=$(date -d "$RAW_CURRENT_STREAK_DATE" +"%b %d, %Y") || CURRENT_STREAK_DISPLAY="N/A"

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 2. Styling Constants
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Vertical Y-coordinates (Locked for alignment)
VAL_Y=100
LBL_Y=155
SUB_Y=195

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 3. Generate Badge
# NOTE: No comments allowed inside the convert block below
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "$MY_FONT" -fill "$TEXT_COLOR" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 283,50 283,200" -draw "line 566,50 566,200" \
    -stroke none -fill "$TEXT_COLOR" -gravity North \
    -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIB" \
    -pointsize 18 -annotate -284+$LBL_Y "Total Contributions" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present" \
    -fill none -stroke "$ORANGE" -strokewidth 5 \
    -draw "arc 370,55 480,165 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,45 Q 415,60 425,75 Q 435,60 425,45 Z'" \
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK" \
    -fill "$ORANGE" -pointsize 18 -annotate +0+$LBL_Y "Current Streak" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present" \
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +284+$VAL_Y "$MAX_STREAK" \
    -pointsize 18 -annotate +284+$LBL_Y "Longest Streak" \
    -pointsize 14 -fill "$SUB_TEXT" -annotate +284+$SUB_Y "All-time High" \
    "$OUTPUT"

echo "Success: Badge generated for $USERNAME"

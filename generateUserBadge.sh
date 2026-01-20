#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Required JSON files for $USERNAME not found."
    exit 1
fi

# 1. Extract and Format Dates
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_MAX_STREAK_DATE=$(jq -r '.maxStreakDate' "$STREAK_FILE")
START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")
# Fallback if maxStreakDate is missing
if [ "$RAW_MAX_STREAK_DATE" != "null" ]; then
    MAX_STREAK_DATE=$(date -d "$RAW_MAX_STREAK_DATE" +"%b %d, %Y")
else
    MAX_STREAK_DATE="N/A"
fi

# 2. Extract Streak Data
STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")
TODAY=$(date +"%b %d")

# 3. Styling - Wider Canvas
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"
OUTPUT="badges/${USERNAME}_badge.png"

mkdir -p badges

# 4. Generate Badge
# We shifted dividers to 280 and 570 to create a balanced three-column layout
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -fill "$TEXT_COLOR" -font "DejaVu-Sans" \
    \
    # --- Column 1: Total (Left) ---
    -gravity West -pointsize 45 -draw "text 80,-20 '$TOTAL_CONTRIB'" \
    -fill "$TEXT_COLOR" -pointsize 18 -draw "text 75,25 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 80,60 '$START_DATE - Present'" \
    \
    # --- Wider Dividers ---
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 280,50 280,200" \
    -draw "line 570,50 570,200" \
    \
    # --- Column 2: Current Streak (Center) ---
    -stroke none -gravity Center \
    -fill none -stroke "$ORANGE" -strokewidth 5 -draw "arc 365,40 485,160 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,30 Q 415,50 425,65 Q 435,50 425,30 Z'" \
    -fill "$TEXT_COLOR" -pointsize 45 -draw "text 0,-15 '$STREAK'" \
    -fill "$ORANGE" -pointsize 18 -draw "text 0,55 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 0,85 '$TODAY - Present'" \
    \
    # --- Column 3: Longest Streak (Right) ---
    -gravity East -fill "$TEXT_COLOR" -pointsize 45 -draw "text 100,-20 '$MAX_STREAK'" \
    -pointsize 18 -draw "text 85,25 'Longest Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 70,60 'All-time High'" \
    \
    "$OUTPUT"

echo "Success: Wide Badge generated for $USERNAME"

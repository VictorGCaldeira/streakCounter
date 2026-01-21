#!/bin/bash

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# 1. Data Extraction & Date Formatting
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

# Vertical Y-coordinates for perfect horizontal alignment
VAL_Y=100   # Large Numbers
LBL_Y=155   # Titles (Total Contrib, Current Streak, etc)
SUB_Y=195   # Dates (Apr 14, 2018, etc)

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 3. Generate Badge
# We use -gravity North -annotate to ensure all text is center-aligned on its X-coordinate
convert -size ${WIDTH}x${HEIGHT} xc:"$BG_COLOR" \
    -font "$MY_FONT" -fill "$TEXT_COLOR" \
    \
    # --- Dividers ---
    -fill none -stroke "$DIVIDER" -strokewidth 2 \
    -draw "line 283,50 283,200" -draw "line 566,50 566,200" \
    \
    # --- Column 1: Total (X=141) ---
    -stroke none -fill "$TEXT_COLOR" -gravity North -pointsize 52 -annotate +284+$VAL_Y "$TOTAL_CONTRIB" \
    -pointsize 18 -annotate +284+$LBL_Y "Total Contributions" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate +284+$SUB_Y "$START_DATE - Present" \
    \
    # --- Column 2: Current Streak (X=425) ---
    -fill none -stroke "$ORANGE" -strokewidth 5 \
    -draw "arc 370,55 480,165 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 425,45 Q 415,60 425,75 Q 435,60 425,45 Z'" \
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK" \
    -fill "$ORANGE" -pointsize 18 -annotate +0+$LBL_Y "Current Streak" \
    -fill "$SUB_TEXT" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present" \
    \
    # --- Column 3: Longest Streak (X=708) ---
    -fill "$TEXT_COLOR" -pointsize 52 -annotate -284+$VAL_Y "$MAX_STREAK" \
    -pointsize 18 -annotate -284+$LBL_Y "Longest Streak" \
    -pointsize 14 -fill "$SUB_TEXT" -annotate -284+$SUB_Y "All-time High" \
    \
    "$OUTPUT"

echo "Alignment fixed by locking Y-axis to $VAL_Y, $LBL_Y, and $SUB_Y."

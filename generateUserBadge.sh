#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

echo "Generating badge with larger (+10%) rotated hollow flame for: $USERNAME"

# 2. Check Data
if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Files not found."
    exit 1
fi

# 3. Extract Data
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_CURRENT_STREAK_DATE=$(jq -r '.currentStreakDate' "$STREAK_FILE")

[[ "$RAW_CREATED_AT" != "null" ]] && START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y") || START_DATE="N/A"
[[ "$RAW_CURRENT_STREAK_DATE" != "null" ]] && CURRENT_STREAK_DISPLAY=$(date -d "$RAW_CURRENT_STREAK_DATE" +"%b %d, %Y") || CURRENT_STREAK_DISPLAY="N/A"

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 4. Styling & Coordinates
WIDTH=850
HEIGHT=250
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# --- COORDINATES ---
VAL_Y=95    # Big Number
LBL_Y=135   # Label
SUB_Y=160   # Date

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT="badges/${USERNAME}_badge.png"
mkdir -p badges

# 5. Build Command
CMD=(
    convert 
    -size "${WIDTH}x${HEIGHT}" 
    xc:"$BG_COLOR"
    -font "$MY_FONT"
    -fill "$TEXT_COLOR"
    
    # --- Vertical Dividers ---
    -fill none -stroke "$DIVIDER" -strokewidth 2
    -draw "line 283,50 283,200"
    -draw "line 566,50 566,200"

    # --- Text Settings ---
    -stroke none -fill "$TEXT_COLOR" -gravity North

    # --- Column 1: Total Contributions ---
    -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIB"
    -pointsize 18 -annotate -284+$LBL_Y "Total Contributions"
    -fill "$SUB_TEXT" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present"

    # --- Column 2: The Ring ---
    -fill none -stroke "$ORANGE" -strokewidth 5
    -draw "arc 330,30 520,220 0,360"
    
    # --- FLAME ICON ---
    
    # 1. Mask (Background Color) - Cuts the circle line
    -fill "$BG_COLOR" -stroke "$BG_COLOR" -strokewidth 8
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 2. Outer Flame (Orange)
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 3. Inner Flame (Hollow Effect - SCALED UP 10% & Rotated)
    # Scaled Coordinates: 
    #   Tip moved up from 16 to 13. 
    #   Base moved down from 36 to 37.
    #   Side control points expanded by ~1px.
    # Rotated 10 degrees clockwise around center.
    -fill "$BG_COLOR" -stroke none
    -draw "translate 425,28 rotate 10 translate -425,-28 path 'M 425,37 C 417,37 417,25 420,20 Q 426,28 432,13 C 437,22 438,37 425,37 Z'"
    
    # --- Column 2: Center Text ---
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK"
    -fill "$ORANGE" -pointsize 18 -annotate +0+$LBL_Y "Current Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present"

    # --- Column 3: Longest Streak ---
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +284+$VAL_Y "$MAX_STREAK"
    -pointsize 18 -annotate +284+$LBL_Y "Longest Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +284+$SUB_Y "All-time High"

    "$OUTPUT"
)

# 6. Execute
"${CMD[@]}"

echo "Success: Badge generated with larger hollow flame."

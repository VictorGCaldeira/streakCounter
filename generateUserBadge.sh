#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

echo "Generating badge with text moved 10px up for: $USERNAME"

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

# --- COORDINATES (Moved UP 10px) ---
VAL_Y=75    # Big Number (Moved from 85 -> 75)
LBL_Y=130   # Label (Moved from 140 -> 130)
SUB_Y=155   # Date (Moved from 165 -> 155)

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
    
    # --- FLAME ICON (UNCHANGED) ---
    
    # 1. Mask (Background Color)
    -fill "$BG_COLOR" -stroke "$BG_COLOR" -strokewidth 8
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 2. Outer Flame (Orange)
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 3. Inner Flame (Hollow Effect)
    # Preserved: Shifted 2px Right (X=422), Rotated 13 degrees
    -fill "$BG_COLOR" -stroke none
    -draw "translate 422,28 rotate 13 translate -422,-28 path 'M 422,37 C 414,37 414,25 417,20 Q 423,28 429,13 C 434,22 435,37 422,37 Z'"
    
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

echo "Success: Badge generated with text moved 10px higher."

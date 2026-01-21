#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

echo "Generating badge with smaller circle and reference flame for: $USERNAME"

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

# --- COORDINATES (Optimized for 190px Circle) ---
# Circle is smaller (Top Y=30, Bottom Y=220). Center Y=125.
# We center the text block around Y=125.
VAL_Y=95    # Big Number (Moved down to center in smaller ring)
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

    # --- Column 2: The Smaller Ring & Flame ---
    # Circle Diameter = 190px (Reduced from 210).
    # Box: 330,30 to 520,220.
    -fill none -stroke "$ORANGE" -strokewidth 5
    -draw "arc 330,30 520,220 0,360"
    
    # --- COMPLEX FLAME ICON (Matches Reference) ---
    # The reference has a "S" curve on the right and a shorter curve on the left.
    # We use Bézier curves (C) to mimic this organic fire shape.
    
    # 1. Mask (Clears the circle line behind the flame)
    -fill "$BG_COLOR" -stroke "$ORANGE" -strokewidth 5
    # Start(425,35) -> LeftBulge -> LeftTip(415,10) -> MidDip(425,20) -> RightTip(435,-5) -> RightBulge -> End(425,35)
    -draw "path 'M 425,35 C 405,35 405,15 415,10 S 425,25 425,20 S 430,-5 435,-5 S 450,20 425,35 Z'"
    
    # 2. Orange Flame Body
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,35 C 405,35 405,15 415,10 S 425,25 425,20 S 430,-5 435,-5 S 450,20 425,35 Z'"
    
    # 3. Inner Hole (Hollow effect)
    -fill "$BG_COLOR" -stroke none
    -draw "path 'M 425,28 Q 415,28 418,18 Q 425,12 432,18 Q 435,28 425,28 Z'"
    
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

echo "Success: Badge generated with smaller circle and custom flame."

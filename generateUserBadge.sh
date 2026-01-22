#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
USER_CONFIG_FILE="config/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# Validate input
if [ -z "$USERNAME" ]; then
    echo "Error: No username provided."
    echo "Usage: $0 <username>"
    exit 1
fi

echo "Generating badge with visible username tag for: $USERNAME"

# 2. Check Data Files
if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Data files not found for user '$USERNAME'."
    exit 1
fi

# Create Config if missing
if [ ! -f "$USER_CONFIG_FILE" ]; then
    mkdir -p config
    cat >"${USER_CONFIG_FILE}" <<EOL
{
  "tagBackgroundColor": "#161b22",
  "tagTextColor": "#8b949e",
  "tagText": "@$USERNAME",
  "tagGen": true
}
EOL
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

# Colors
BG_COLOR="#0d1117"
# Use -r to get raw strings, ensure colors have quotes in JSON or handle them here
TAG_BG_COLOR=$(jq -r '.tagBackgroundColor' "$USER_CONFIG_FILE")
TEXT_COLOR="#ffffff"
TAG_TEXT_COLOR=$(jq -r '.tagTextColor' "$USER_CONFIG_FILE")
TAG_TEXT=$(jq -r '.tagText' "$USER_CONFIG_FILE")
TAG_GEN=$(jq -r '.tagGen' "$USER_CONFIG_FILE")
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Content Coordinates (Top Align)
VAL_Y=65    # Big Number
LBL_Y=120   # Label
SUB_Y=145   # Date

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT_DIR="badges"
OUTPUT="${OUTPUT_DIR}/${USERNAME}_badge.png"
mkdir -p "$OUTPUT_DIR"

CMD=(
    convert 
)

if [[ "$TAG_GEN" == "true" ]]; then
    HEIGHT=310
    TAG_=50
    TAG_START_Y=$((HEIGHT - TAG_HEIGHT))
    TAG_IMAGE_START_Y=$((HEIGHT))
    CMD+=(
        -draw "image SrcOver 0,0 $WIDTH,$TAG_HEIGHT images/tagBG.jpg"
        -fill "$TAG_BG_COLOR" -stroke none
        -draw "rectangle 0,$TAG_IMAGE_START_Y $WIDTH,$HEIGHT"
        -fill "$TAG_TEXT_COLOR" 
        -pointsize 20 
        -gravity South
        -annotate +0+15 "$TAG_TEXT"
    )
fi

CMD+=(
    -size "${WIDTH}x${HEIGHT}" 
    xc:"$BG_COLOR"
    -font "$MY_FONT"
)

# --- 3. Main Content (Append to array) ---
CMD+=(
    # Switch back to Top Alignment
    -gravity North

    # Vertical Dividers
    -fill none -stroke "$DIVIDER" -strokewidth 2
    -draw "line 283,50 283,200"
    -draw "line 566,50 566,200"

    # Main Text Columns
    -stroke none -fill "$TEXT_COLOR"

    # Column 1: Total Contributions
    -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIB"
    -pointsize 18 -annotate -284+$LBL_Y "Total Contributions"
    -fill "$SUB_TEXT" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present"

    # Column 2: The Ring
    -fill none -stroke "$ORANGE" -strokewidth 5
    -draw "arc 330,30 520,220 0,360"
    
    # --- FLAME ICON ---
    # 1. Mask
    -fill "$BG_COLOR" -stroke "$BG_COLOR" -strokewidth 8
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 2. Outer Flame
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 3. Inner Flame (Hollow Effect)
    -fill "$BG_COLOR" -stroke none
    -draw "translate 422,28 rotate 13 translate -422,-28 path 'M 422,37 C 414,37 414,25 417,20 Q 423,28 429,13 C 434,22 435,37 422,37 Z'"
    
    # Column 2: Center Text
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK"
    -fill "$ORANGE" -pointsize 18 -annotate +0+$LBL_Y "Current Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present"

    # Column 3: Longest Streak
    -fill "$TEXT_COLOR" -pointsize 52 -annotate +284+$VAL_Y "$MAX_STREAK"
    -pointsize 18 -annotate +284+$LBL_Y "Longest Streak"
    -fill "$SUB_TEXT" -pointsize 14 -annotate +284+$SUB_Y "All-time High"

    "$OUTPUT"
)

# 6. Execute
"${CMD[@]}"

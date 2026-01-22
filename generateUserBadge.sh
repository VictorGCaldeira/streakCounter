#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

# Validate input
if [ -z "$USERNAME" ]; then
    echo "Error: No username provided."
    echo "Usage: $0 <username>"
    exit 1
fi

echo "Generating larger badge with username tag for: $USERNAME"

# 2. Check Data Files
if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Data files not found for user '$USERNAME'."
    echo "Please ensure 'data/${USERNAME}.json' and 'streakData/${USERNAME}.json' exist."
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
# INCREASED HEIGHT from 250 to 310 to fit the new tag area
HEIGHT=310

# Colors
BG_COLOR="#0d1117"
TAG_BG_COLOR="#161b22"  # Slightly lighter for the footer tag
TEXT_COLOR="#ffffff"
TAG_TEXT_COLOR="#c9d1d9" # Off-white for tag text
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"

# Main Content Coordinates (Preserved from previous step)
VAL_Y=65    # Big Number
LBL_Y=120   # Label
SUB_Y=145   # Date

# Tag Coordinates
TAG_Y_START=250
TAG_TEXT_Y=288

# Font Selection
MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT_DIR="badges"
OUTPUT="${OUTPUT_DIR}/${USERNAME}_badge.png"
mkdir -p "$OUTPUT_DIR"

# 5. Build Command
CMD=(
    convert 
    -size "${WIDTH}x${HEIGHT}" 
    xc:"$BG_COLOR"
    -font "$MY_FONT"
    
    # --- 1. Draw Tag Background (Bottom Area) ---
    -fill "$TAG_BG_COLOR" -stroke none
    -draw "rectangle 0,$TAG_Y_START $WIDTH,$HEIGHT"

    # --- 2. Draw Tag Text ---
    -fill "$TAG_TEXT_COLOR" -pointsize 20 -gravity North
    -annotate +0+$TAG_TEXT_Y "@$USERNAME"

    # --- 3. Draw Main Content Dividers ---
    -fill none -stroke "$DIVIDER" -strokewidth 2
    -draw "line 283,50 283,200"
    -draw "line 566,50 566,200"

    # --- 4. Text Settings for Main Content ---
    -stroke none -fill "$TEXT_COLOR" -gravity North

    # --- Column 1: Total Contributions ---
    -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIB"
    -pointsize 18 -annotate -284+$LBL_Y "Total Contributions"
    -fill "$SUB_TEXT" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present"

    # --- Column 2: The Ring ---
    -fill none -stroke "$ORANGE" -strokewidth 5
    -draw "arc 330,30 520,220 0,360"
    
    # --- FLAME ICON (UNCHANGED) ---
    # 1. Mask
    -fill "$BG_COLOR" -stroke "$BG_COLOR" -strokewidth 8
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 2. Outer Flame
    -fill "$ORANGE" -stroke none
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    
    # 3. Inner Flame (Hollow Effect)
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

echo "Success: Badge generated with increased size and username tag."

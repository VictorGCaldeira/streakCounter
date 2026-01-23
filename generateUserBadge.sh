#!/bin/bash

# 1. Safety & Settings
set -e
export LC_NUMERIC="C"

USERNAME=$1
USER_FILE="${USERNAME}/data/${USERNAME}.json"
USER_CONFIG_FILE="${USERNAME}/config/${USERNAME}.json"
STREAK_FILE="${USERNAME}/streakData/${USERNAME}.json"

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
mkdir -p "${USERNAME}/images"
touch "${USERNAME}/images/.keep"
# Create Config if missing
if [ ! -f "$USER_CONFIG_FILE" ]; then
    mkdir -p "${USERNAME}/config"
    cat >"${USER_CONFIG_FILE}" <<EOL
{
  "backgroundColor": "#0d1117",
  "tagBackgroundColor": "#161b22",
  "tagTextColor": "#8b949e",
  "tagText": "@$USERNAME",
  "tagGen": true,
  "tagImage": "",
  "backgroundImage": "",
  "flameColor":"#ff9a00",
  "flameBlur": false,
  "flameBlurForce": "0x2",
  "ringColor":"#ff9a00",
  "ringBlur":false,
  "ringBlurForce": "0x2",
  "totalContributedColor": "#ffffff",
  "totalContributedTextColor": "#ffffff",
  "totalContributedSubTextColor": "#8b949e",
  "streakColor": "#ffffff",
  "streakTextColor": "#ff9a00",
  "streakSubTextColor": "#8b949e",
  "maxStreakColor": "#ffffff",
  "maxStreakTextColor": "#ffffff",
  "maxStreakSubTextColor": "#8b949e"
}
EOL
fi

# 3. Extract Data
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
RAW_CURRENT_STREAK_DATE=$(jq -r '.currentStreakDate' "$STREAK_FILE")

[[ "$RAW_CREATED_AT" != "null" ]] && START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y") || START_DATE="N/A"
[[ "$RAW_CURRENT_STREAK_DATE" != "null" ]] && CURRENT_STREAK_DISPLAY=$(date -d "$RAW_CURRENT_STREAK_DATE" +"%b %d, %Y") || CURRENT_STREAK_DISPLAY="N/A"

STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIBUTED=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")

# 4. Styling & Coordinates
WIDTH=850
HEIGHT=250

# Colors
BG_COLOR=$(jq -r '.backgroundColor' "$USER_CONFIG_FILE")
TAG_BG_COLOR=$(jq -r '.tagBackgroundColor' "$USER_CONFIG_FILE")
TEXT_COLOR="#ffffff"
TAG_TEXT_COLOR=$(jq -r '.tagTextColor' "$USER_CONFIG_FILE")
TAG_TEXT=$(jq -r '.tagText' "$USER_CONFIG_FILE")
TAG_GEN=$(jq -r '.tagGen' "$USER_CONFIG_FILE")
TAG_IMAGE=$(jq -r '.tagImage' "$USER_CONFIG_FILE")
BACKGROUND_IMAGE=$(jq -r '.backgroundImage' "$USER_CONFIG_FILE")
FLAME_COLOR=$(jq -r '.flameColor' "$USER_CONFIG_FILE")
FLAME_BLUR=$(jq -r '.flameBlur' "$USER_CONFIG_FILE")
FLAME_BLUR_FORCE=$(jq -r '.flameBlurForce' "$USER_CONFIG_FILE")
RING_COLOR=$(jq -r '.ringColor' "$USER_CONFIG_FILE")
RING_BLUR=$(jq -r '.ringBlur' "$USER_CONFIG_FILE")
RING_BLUR_FORCE=$(jq -r '.ringBlurForce' "$USER_CONFIG_FILE")
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"
TOTAL_CONTRIBUTED_COLOR=$(jq -r '.totalContributedColor' "$USER_CONFIG_FILE")
TOTAL_CONTRIBUTED_TEXT_COLOR=$(jq -r '.totalContributedTextColor' "$USER_CONFIG_FILE")
TOTAL_CONTRIBUTED_SUB_TEXT_COLOR=$(jq -r '.totalContributedSubTextColor' "$USER_CONFIG_FILE")
STREAK_COLOR=$(jq -r '.streakColor' "$USER_CONFIG_FILE")
STREAK_TEXT_COLOR=$(jq -r '.streakTextColor' "$USER_CONFIG_FILE")
STREAK_SUB_TEXT_COLOR=$(jq -r '.streakSubTextColor' "$USER_CONFIG_FILE")
MAX_STREAK_COLOR=$(jq -r '.maxStreakColor' "$USER_CONFIG_FILE")
MAX_STREAK_TEXT_COLOR=$(jq -r '.maxStreakTextColor' "$USER_CONFIG_FILE")
MAX_STREAK_SUB_TEXT_COLOR=$(jq -r '.maxStreakSubTextColor' "$USER_CONFIG_FILE")
# Content Coordinates (Top Align)
VAL_Y=65    # Big Number
LBL_Y=120   # Label
SUB_Y=145   # Date

MY_FONT=$(convert -list font | grep -oE "Arial|Liberation-Sans|DejaVu-Sans" | head -n 1)
[ -z "$MY_FONT" ] && MY_FONT="fixed"

OUTPUT_DIR="${USERNAME}/badges"
OUTPUT="${OUTPUT_DIR}/${USERNAME}_badge.png"
mkdir -p "$OUTPUT_DIR"

CMD=(
    convert 
)

if [[ "$TAG_GEN" == "true" ]]; then
    HEIGHT=310
    TAG_HEIGHT=50
    TAG_START_Y=$((HEIGHT - TAG_HEIGHT))
    TAG_IMAGE_START_Y=$((HEIGHT))
    if [[ ${#TAG_IMAGE} -gt 4 ]]; then
        CMD+=(
        -draw "image SrcOver 0,0 $WIDTH,$TAG_HEIGHT $TAG_IMAGE"
        )
    fi
    CMD+=(
        -fill "$TAG_BG_COLOR" -stroke none
        -draw "rectangle 0,$TAG_IMAGE_START_Y $WIDTH,$HEIGHT"
        -fill "$TAG_TEXT_COLOR" 
        -pointsize 20 
        -gravity South
        -annotate +0+15 "$TAG_TEXT"
    )
fi
if [[ ${#BACKGROUND_IMAGE} -gt 4 ]]; then
        CMD+=(
        -draw "image SrcOver 0,0 $WIDTH,$HEIGHT $BACKGROUND_IMAGE"
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

    -fill "$TOTAL_CONTRIBUTED_COLOR" -pointsize 52 -annotate -284+$VAL_Y "$TOTAL_CONTRIBUTED"
    -fill "$TOTAL_CONTRIBUTED_TEXT_COLOR" -pointsize 18 -annotate -284+$LBL_Y "Total Contributions"
    -fill "$TOTAL_CONTRIBUTED_SUB_TEXT_COLOR" -pointsize 14 -annotate -284+$SUB_Y "$START_DATE - Present"
    )

    # Column 2: The Ring
    if [[ "$RING_BLUR" == "true" ]]; then
    CMD+=( "(" 
        -size "${WIDTH}x${HEIGHT}" xc:none 
        -fill none -stroke "$RING_COLOR" -strokewidth 5
        -draw "arc 330,30 520,220 0,360"
        -blur $RING_BLUR_FORCE
    ")" 
    -composite)
    else
    CMD+=(
        -fill none -stroke "$RING_COLOR" -strokewidth 5
        -draw "arc 330,30 520,220 0,360")
    fi
    CMD+=(
    # --- FLAME ICON ---
    # 1. Mask (Hides the ring behind the flame - STAYS ON MAIN LAYER)
    -fill "$BG_COLOR" -stroke "$BG_COLOR" -strokewidth 8
    -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'"
    )
    
    # 2. Outer Flame (ISOLATED LAYER for Blur)
    # We create a new transparent canvas, draw the flame, blur it, then composite it back.
    if [[ "$FLAME_BLUR" == "true" ]]; then
    CMD+=( "(" 
        -size "${WIDTH}x${HEIGHT}" xc:none 
        -fill "$FLAME_COLOR" -stroke none 
        -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'" 
        -blur $FLAME_BLUR_FORCE
    ")" 
    -composite)
    else
    CMD+=(
        -fill "$FLAME_COLOR" -stroke none 
        -draw "path 'M 425,42 C 405,42 402,20 414,12 Q 424,25 434,0 C 445,12 445,42 425,42 Z'" )
    fi
    CMD+=(    
    # 3. Inner Flame (Hollow Effect - SHARP)
    -fill "$BG_COLOR" -stroke none
    -draw "translate 422,28 rotate 13 translate -422,-28 path 'M 422,37 C 414,37 414,25 417,20 Q 423,28 429,13 C 434,22 435,37 422,37 Z'"
    
    # Column 2: Center Text
    -fill "$STREAK_COLOR" -pointsize 52 -annotate +0+$VAL_Y "$STREAK"
    -fill "$STREAK_TEXT_COLOR" -pointsize 18 -annotate +0+$LBL_Y "Current Streak"
    -fill "$STREAK_SUB_TEXT_COLOR" -pointsize 14 -annotate +0+$SUB_Y "$CURRENT_STREAK_DISPLAY - Present"

    # Column 3: Longest Streak
    -fill "$MAX_STREAK_COLOR" -pointsize 52 -annotate +284+$VAL_Y "$MAX_STREAK"
    -fill "$MAX_STREAK_TEXT_COLOR" -pointsize 18 -annotate +284+$LBL_Y "Longest Streak"
    -fill "$MAX_STREAK_SUB_TEXT_COLOR" -pointsize 14 -annotate +284+$SUB_Y "All-time High"

    "$OUTPUT"
)

# 6. Execute
"${CMD[@]}"

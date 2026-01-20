USERNAME=$1
# We need both files: the raw user data and the calculated streak data
USER_FILE="data/${USERNAME}.json"
STREAK_FILE="streakData/${USERNAME}.json"

if [ ! -f "$USER_FILE" ] || [ ! -f "$STREAK_FILE" ]; then
    echo "Error: Required JSON files for $USERNAME not found."
    exit 1
fi

# 1. Extract and Format the Account Creation Date
# Extracts "2018-04-14T..." and converts to "Apr 14, 2018"
RAW_CREATED_AT=$(jq -r '.user.createdAt' "$USER_FILE")
START_DATE=$(date -d "$RAW_CREATED_AT" +"%b %d, %Y")

# 2. Extract Streak Data
STREAK=$(jq -r '.streakCount' "$STREAK_FILE")
TOTAL_CONTRIB=$(jq -r '.contributionCount' "$STREAK_FILE")
MAX_STREAK=$(jq -r '.maxStreak' "$STREAK_FILE")
TODAY=$(date +"%b %d")

# 3. Styling
BG_COLOR="#0d1117"
TEXT_COLOR="#ffffff"
ORANGE="#ff9a00"
SUB_TEXT="#8b949e"
DIVIDER="#30363d"
OUTPUT="badges/${USERNAME}_badge.png"

mkdir -p badges

# 4. Generate Badge
convert -size 650x250 xc:"$BG_COLOR" \
    -fill "$TEXT_COLOR" -font "DejaVu-Sans" \
    -gravity West -pointsize 45 -draw "text 60,-20 '$TOTAL_CONTRIB'" \
    -fill "$TEXT_COLOR" -pointsize 18 -draw "text 55,25 'Total Contributions'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 60,60 '$START_DATE - Present'" \
    -fill none -stroke "$DIVIDER" -strokewidth 2 -draw "line 215,50 215,200" \
    -draw "line 435,50 435,200" \
    -stroke none -gravity Center \
    -fill none -stroke "$ORANGE" -strokewidth 5 -draw "arc 265,40 385,160 140,400" \
    -fill "$ORANGE" -stroke none -draw "path 'M 325,30 Q 315,50 325,65 Q 335,50 325,30 Z'" \
    -fill "$TEXT_COLOR" -pointsize 45 -draw "text 0,-15 '$STREAK'" \
    -fill "$ORANGE" -pointsize 18 -draw "text 0,55 'Current Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 0,85 '$TODAY - Present'" \
    -gravity East -fill "$TEXT_COLOR" -pointsize 45 -draw "text 80,-20 '$MAX_STREAK'" \
    -pointsize 18 -draw "text 65,25 'Longest Streak'" \
    -fill "$SUB_TEXT" -pointsize 14 -draw "text 50,60 'All-time High'" \
    "$OUTPUT"

echo "Success: Badge generated for $USERNAME (Started: $START_DATE)"

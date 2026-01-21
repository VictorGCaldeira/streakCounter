#!/bin/bash
USERNAME=$1
STREAK_COUNT=0
CONTRIBUTION_COUNT=0
AVG_CONTRIBUTION=0
TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
CONTRIBUTION_DAYS_COUNT=$(cat "contributions/${USERNAME}.json" | jq -r '[.[] | select(.date < "'$TODAY'")] | length')
MAX_STREAK=0
INDEX=0
MAX_STREAK_DATE=null
CURRENT_STREAK_DATE=null
while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
    if [[ $STREAK_COUNT -eq 1 ]]; then
      CURRENT_STREAK_DATE=$(cat "contributions/${USERNAME}.json" | jq -r '.['$INDEX'].date')
    fi
    CONTRIBUTION_COUNT=$(( CONTRIBUTION_COUNT + count ))
    if [[ $STREAK_COUNT -gt $MAX_STREAK ]]; then
      MAX_STREAK=$STREAK_COUNT
      MAX_STREAK_DATE=$(cat "contributions/${USERNAME}.json" | jq -r '.['$(( $INDEX - $MAX_STREAK))'].date')
    fi
  else
    CURRENT_STREAK_DATE=$(cat "contributions/${USERNAME}.json" | jq -r '.['$INDEX'].date')
    STREAK_COUNT=0
  fi
  INDEX=$(( $INDEX + 1 ))
done < <(jq -r '.[] | select(.date < "'$TODAY'") | .contributionCount' "contributions/${USERNAME}.json")
if [[ $CONTRIBUTION_DAYS_COUNT -gt 0 ]]; then
  AVG_CONTRIBUTION=$((CONTRIBUTION_COUNT / $CONTRIBUTION_DAYS_COUNT ))
fi
echo $USERNAME streak is $STREAK_COUNT total contributions $CONTRIBUTION_COUNT avg contributions per day $AVG_CONTRIBUTION best streak is $MAX_STREAK

mkdir -p streakData
cat >"streakData/${USERNAME}.json" <<EOL
{
  "username": "$USERNAME",
  "streakCount": "$STREAK_COUNT",
  "contributionCount": "$CONTRIBUTION_COUNT",
  "avgContribution": "$AVG_CONTRIBUTION",
  "maxStreak": "$MAX_STREAK",
  "maxStreakDate": "$MAX_STREAK_DATE",
  "currentStreakDate": "$CURRENT_STREAK_DATE"
}
EOL

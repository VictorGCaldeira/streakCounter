#!/bin/bash
USERNAME=$1
STREAK_COUNT=0
CONTRIBUTION_COUNT=0
AVG_CONTRIBUTION=0
TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
TODAY_YEAR=${TODAY:0:4}
CONTRIBUTION_DAYS_COUNT=$(jq -r '[.[] | select(.date < "'$TODAY'")] | length' "${USERNAME}/contributions/${USERNAME}.json")
MAX_STREAK=0
INDEX=0
MAX_STREAK_DATE=null
CURRENT_STREAK_DATE=null
FIRST_CONTRIBUTION_DATE=$(jq -r '.[0].date' "${USERNAME}/contributions/${USERNAME}.json")
FIRST_CONTRIBUTION_YEAR=${FIRST_CONTRIBUTION_DATE:0:4}
MAX_CONTRIBUTION=0

declare -a YEARS_CONTRIBUTION
while read -r contribution; 
do 
  CONTRIBUTION_COUNT=$(echo $contribution | jq -r ".contributionCount")
  CONTRIBUTION_DATE=$(echo $contribution | jq -r ".date")
  CONTRIBUTION_YEAR=${CONTRIBUTION_DATE:0:4}
  YEARS_CONTRIBUTION[CONTRIBUTION_YEAR]=$(( YEARS_CONTRIBUTION[CONTRIBUTION_YEAR] + CONTRIBUTION_COUNT ))
  if [[ $CONTRIBUTION_COUNT -gt 0 ]]; then
    if [[ $CONTRIBUTION_COUNT -gt $MAX_CONTRIBUTION ]]; then
      MAX_CONTRIBUTION=$CONTRIBUTION_COUNT
    fi 
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
    if [[ $STREAK_COUNT -eq 1 ]]; then
      CURRENT_STREAK_DATE=$(cat "${USERNAME}/contributions/${USERNAME}.json" | jq -r '.['$INDEX'].date')
    fi
    if [[ $STREAK_COUNT -gt $MAX_STREAK ]]; then
      MAX_STREAK=$STREAK_COUNT
      MAX_STREAK_DATE=$(cat "${USERNAME}/contributions/${USERNAME}.json" | jq -r '.['$(( $INDEX - $MAX_STREAK))'].date')
    fi
    CONTRIBUTION_COUNT=$(( CONTRIBUTION_COUNT + CONTRIBUTION_COUNT ))
  else
    CURRENT_STREAK_DATE=$(cat "${USERNAME}/contributions/${USERNAME}.json" | jq -r '.['$INDEX'].date')
    STREAK_COUNT=0
  fi
  INDEX=$(( $INDEX + 1 ))
done < <(jq -c '.[] | select(.date < "'$TODAY'")' "${USERNAME}/contributions/${USERNAME}.json")
if [[ $CONTRIBUTION_DAYS_COUNT -gt 0 ]]; then
  AVG_CONTRIBUTION=$((CONTRIBUTION_COUNT / $CONTRIBUTION_DAYS_COUNT ))
fi
echo $USERNAME streak is $STREAK_COUNT total contributions $CONTRIBUTION_COUNT avg contributions per day $AVG_CONTRIBUTION best streak is $MAX_STREAK
echo ${YEARS_CONTRIBUTION["2018"]}
echo $YEARS_CONTRIBUTION
CONTRIBUTION_PER_YEAR=""
for i in $(seq $FIRST_CONTRIBUTION_YEAR $TODAY_YEAR)
do
  CONTRIBUTION_PER_YEAR+="{"
  CONTRIBUTION_PER_YEAR+='"year":"'$i'",'
  YEAR_CONTRIBUTION=${YEARS_CONTRIBUTION[$i]}
  CONTRIBUTION_PER_YEAR+='"totalContributed":"'$YEAR_CONTRIBUTION'",'
  CONTRIBUTION_PER_YEAR+='"avg":"'$((YEAR_CONTRIBUTION / 365))'"'
  if [[ i -eq $TODAY_YEAR ]]; then
    CONTRIBUTION_PER_YEAR+="}"
  else
    CONTRIBUTION_PER_YEAR+="},"
  fi
done
mkdir -p "${USERNAME}/streakData"
cat >"${USERNAME}/streakData/${USERNAME}.json" <<EOL
{
  "username": "$USERNAME",
  "streakCount": "$STREAK_COUNT",
  "contributionCount": "$CONTRIBUTION_COUNT",
  "maxContribution": "$MAX_CONTRIBUTION",
  "avgContribution": "$AVG_CONTRIBUTION",
  "maxStreak": "$MAX_STREAK",
  "maxStreakDate": "$MAX_STREAK_DATE",
  "currentStreakDate": "$CURRENT_STREAK_DATE",
  "contributionPerYear": [$CONTRIBUTION_PER_YEAR]
}
EOL

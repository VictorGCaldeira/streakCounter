#!/bin/bash 
USERNAME=$1
CONTRIBUTION_DAYS_COUNT=$(jq -r '[.[] | select(.date < "'$TODAY'")] | length' "contributions/${USERNAME}.json")
MAX_CONTRIBUTION=0
WEEK_DAY=0
WEEK_COUNT=0
mkdir -p statistics
DAY_COMMITMENT_DATA+="["
WEEK_NUMBER+="["
while read -r contribution; 
do 
  echo here
  CONTRIBUTION_COUNT=$(echo $contribution | jq -r ".contributionCount")
  CONTRIBUTION_DATE=$(echo $contribution | jq -r ".date")
  CONTRIBUTION_YEAR=${CONTRIBUTION_DATE:0:4}
  if [[ $CONTRIBUTION_COUNT -gt $MAX_CONTRIBUTION ]]; then
    MAX_CONTRIBUTION=$CONTRIBUTION_COUNT
  fi 
  DAY_COMMITMENT_DATA+='['$WEEK_DAY','$WEEK_COUNT','$CONTRIBUTION_COUNT'],'
  WEEK_NUMBER+='"'$WEEK_COUNT' '$CONTRIBUTION_YEAR'",'
  if [[ WEEK_DAY -ge 6 ]]; then
    WEEK_DAY=0
    WEEK_COUNT=$(( $WEEK_COUNT + 1 ))
  fi
  WEEK_DAY=$(( $WEEK_DAY + 1 ))
  INDEX=$(( $INDEX + 1 ))
done < <(jq -c '.[] | select(.date < "'$TODAY'")' "contributions/${USERNAME}.json")
DAY_COMMITMENT_DATA+="]"
WEEK_NUMBER="]"
mkdir -p streakData
cat >"statistics/${USERNAME}.json" <<EOL
{
  "maxContribution": "$MAX_CONTRIBUTION",
  "contributionDaysCount": "$CONTRIBUTION_DAYS_COUNT",
  "dayCommitmentData": $DAY_COMMITMENT_DATA,
  "weekNumber": $WEEK_NUMBER
}
EOL

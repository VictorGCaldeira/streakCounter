USERNAME=$1
STREAK_COUNT=0
CONTRIBUTION_COUNT=0

TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
CONTRIBUTION_DAYS_COUNT=$(cat "contributions/${USERNAME}.json" | jq -r '[.[] | select(.date < "'$TODAY'")] | length')
while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
    CONTRIBUTION_COUNT=$(( CONTRIBUTION_COUNT + count ))
  else
    STREAK_COUNT=0
  fi
done < <(jq -r '.[] | select(.date < "'$TODAY'") | .contributionCount' "contributions/${USERNAME}.json")
echo contr $CONTRIBUTION_DAYS_COUNT
AVG_CONTRIBUTION=$((CONTRIBUTION_COUNT / $CONTRIBUTION_DAYS_COUNT ))
echo $USERNAME streak is $STREAK_COUNT total contributions $CONTRIBUTION_COUNT avg contributions per day $AVG_CONTRIBUTION

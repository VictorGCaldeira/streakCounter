USERNAME=$1
STREAK_COUNT=0
CONTRIBUTION_COUNT=0

TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
    CONTRIBUTION_COUNT=$(( CONTRIBUTION_COUNT + count ))
  else
    STREAK_COUNT=0
  fi
done < <(jq -r '.[] | select(.date < "'$TODAY'") | .contributionCount' "contributions/${USERNAME}.json")
AVG_CONTRIBUTION=$((CONTRIBUTION_COUNT/$(jq -r '.[] | select(.date < "'$TODAY'") | .length')))
echo $USERNAME streak is $STREAK_COUNT total contributions $CONTRIBUTION_COUNT avg contributions per day $AVG_CONTRIBUTION

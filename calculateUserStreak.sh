USERNAME=$1
STREAK_COUNT=0
TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
  else
    STREAK_COUNT=0
  fi
done < <(jq -r '.[] | select(.date < "'$TODAY'") | .contributionCount' "contributions/${USERNAME}.json")

echo $USERNAME streak is $STREAK_COUNT

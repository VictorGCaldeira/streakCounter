USERNAME=$1
STREAK_COUNT=0
TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")
cat "contributions/${USERNAME}.json" | jq '.[] | [select(.date < "'$TODAY'")] | .[].contributionCount' | while read -r count; 
do 
  if [[ $count -gt 0 ]]; then
    STREAK_COUNT=$(( STREAK_COUNT + 1 ))
    echo $STREAK_COUNT
  else
    STREAK_COUNT=0
  fi
done

echo $USERNAME streak is $STREAK_COUNT

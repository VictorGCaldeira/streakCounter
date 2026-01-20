USERNAME=$1
GITHUB_PAT=$2
EVENTS=$(curl -S --location 'https://api.github.com/graphql' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $GITHUB_PAT" \
--data '{
    "query": "query { user(login: \"juancolchete\") { name createdAt  } }"
}')
TODAY_YEAR=$(date -u +"%Y")
ACCOUNT_CREATED_AT=$(echo $EVENTS | jq -r '.data.user.createdAt')
ACCOUNT_CREATED_AT_YEAR=${ACCOUNT_CREATED_AT:0:4}
RUN_YEAR=$ACCOUNT_CREATED_AT_YEAR
echo "[]" > "${USERNAME}Contributions.json"

for i in $(seq $ACCOUNT_CREATED_AT_YEAR $TODAY_YEAR)
do
    RESPONSE=$(curl -S --location 'https://api.github.com/graphql' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $GITHUB_PAT" \
    --data '{
        "query": "query { user(login: \"juancolchete\") { name createdAt contributionsCollection(from: \"'$RUN_YEAR'-01-01T00:00:00Z\") { startedAt contributionCalendar { totalContributions weeks { contributionDays { date contributionCount } } } } } }"
    }')
    NEW_DAYS=$(echo $RESPONSE | jq '[.data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]] | .[:-1]')
    RUN_YEAR=$((RUN_YEAR + 1))
    jq -n --slurpfile old "${USERNAME}Contributions.json" --argjson new "$NEW_DAYS" '($old | add) + $new' > "temp.json" && mv "temp.json" "${USERNAME}Contributions.json"
done

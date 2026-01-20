USERNAME=$1
GITHUB_PAT=$2
EVENTS=$(curl --location 'https://api.github.com/graphql' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $GITHUB_PAT" \
--data '{
    "query": "query { user(login: \"juancolchete\") { name createdAt  } }"
}')
TODAY_YEAR=$(date -u +"%Y")
ACCOUNT_CREATED_AT=$(echo $EVENTS | jq -r '.data.user.createdAt')
ACCOUNT_CREATED_AT_YEAR=${ACCOUNT_CREATED_AT:0:4}
YEARS_TO_RUN=$((TODAY_YEAR - ACCOUNT_CREATED_AT_YEAR))
echo "acccvre"
echo "$YEARS_TO_RUN"
EVENTS=$(curl --location 'https://api.github.com/graphql' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $GITHUB_PAT" \
--data '{
    "query": "query { user(login: \"juancolchete\") { name createdAt contributionsCollection(from: \"'$ACCOUNT_CREATED_AT_YEAR'-01-01T00:00:00Z\") { startedAt contributionCalendar { totalContributions weeks { contributionDays { date contributionCount } } } } } }"
}')
echo $EVENTS | jq '[.data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]] | .[:-1]' > "$USERNAMEContributions.json"
echo $USERNAME started at $ACCOUNT_CREATED_AT streak 9000
cat "$USERNAMEContributions.json"

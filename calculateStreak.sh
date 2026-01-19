USERNAME=$1
GITHUB_PAT=$2
EVENTS=$(curl --location 'https://api.github.com/graphql' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $GITHUB_PAT" \
--data '{
    "query": "query { user(login: \"juancolchete\") { name createdAt contributionsCollection { startedAt contributionCalendar { totalContributions weeks { contributionDays { date contributionCount } } } } } }"
}')
echo $EVENTS

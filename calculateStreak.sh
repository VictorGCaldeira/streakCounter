USERNAME=$1
GITHUB_PAT=$(cat gitPAT.txt)
EVENTS=$(curl --location 'https://api.github.com/graphql' \
--header 'Content-Type: application/json' \
--header "Authorization: $GITHUB_PAT" \
--data '{
    "query": "query { user(login: \"juancolchete\") { name createdAt contributionsCollection { startedAt contributionCalendar { totalContributions weeks { contributionDays { date contributionCount } } } } } }"
}')
echo $EVENTS

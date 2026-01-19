$USERNAME=$1
EVENTS=$(curl -s "https://api.github.com/users/$USERNAME/events")
echo $EVENTS

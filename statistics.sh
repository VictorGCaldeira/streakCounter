#!/bin/bash 
USERNAME=$1
TODAY=$(date -u +"%Y-%m-%d" -d "-3 hours")

CONTRIBUTION_DAYS_COUNT=$(jq -r '[.[] | select(.date < "'$TODAY'")] | length' "contributions/${USERNAME}.json")
MAX_CONTRIBUTION=0
WEEK_DAY=0
WEEK_COUNT=0
GLOBAL_WEEK_COUNT=0
FIRST_CONTRIBUTION_DATE=$(jq -r '.[0].date' "contributions/${USERNAME}.json")
FIRST_CONTRIBUTION_YEAR=${FIRST_CONTRIBUTION_DATE:0:4}
CURRENT_CONTRIBUTION_YEAR=$FIRST_CONTRIBUTION_YEAR
mkdir -p statistics
DAY_COMMITMENT_DATA+="["
WEEK_NUMBER+="["
while read -r contribution; 
do 
  CONTRIBUTION_COUNT=$(echo $contribution | jq -r ".contributionCount")
  CONTRIBUTION_DATE=$(echo $contribution | jq -r ".date")
  CONTRIBUTION_YEAR=${CONTRIBUTION_DATE:0:4}
  if [[ $CONTRIBUTION_COUNT -gt $MAX_CONTRIBUTION ]]; then
    MAX_CONTRIBUTION=$CONTRIBUTION_COUNT
  fi 
  DAY_COMMITMENT_DATA+='['$WEEK_DAY','$WEEK_COUNT','$CONTRIBUTION_COUNT'],'
  if [[ WEEK_DAY -ge 6 ]]; then
    WEEK_DAY=0
    if [[ $CONTRIBUTION_YEAR -gt $CURRENT_CONTRIBUTION_YEAR ]]; then
      CURRENT_CONTRIBUTION_YEAR=$CONTRIBUTION_YEAR
      # WEEK_COUNT=0
    fi
    WEEK_COUNT=$(( $WEEK_COUNT + 1 ))
    WEEK_NUMBER+=''$WEEK_COUNT','
    GLOBAL_WEEK_COUNT=$(( $GLOBAL_WEEK_COUNT + 1 ))
    # WEEK_NUMBER+='"'$WEEK_COUNT' '$CONTRIBUTION_YEAR'",'
  fi
  WEEK_DAY=$(( $WEEK_DAY + 1 ))
  INDEX=$(( $INDEX + 1 ))
done < <(jq -c '.[] | select(.date < "'$TODAY'")' "contributions/${USERNAME}.json")
DAY_COMMITMENT_DATA+="]"
WEEK_NUMBER+="]"
mkdir -p streakData
cat >"statistics/${USERNAME}.json" <<EOL
{
  "maxContribution": "$MAX_CONTRIBUTION",
  "contributionDaysCount": "$CONTRIBUTION_DAYS_COUNT",
  "dayCommitmentData": $DAY_COMMITMENT_DATA,
  "weekNumber": $WEEK_NUMBER
}
EOL

cat >"statistics/${USERNAME}Data.js" <<EOL
const maxContribution=$MAX_CONTRIBUTION
const contributionDaysCount=$CONTRIBUTION_DAYS_COUNT
const dayCommitmentData=$DAY_COMMITMENT_DATA
const weekNumber=$WEEK_NUMBER
EOL

cat >"statistics/${USERNAME}.html" <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>$USERNAME - Skyscraper</title>
  <link rel="stylesheet" href="./style.css">
</head>
<body>
  <div id="chart-container"></div>
  <script src="https://echarts.apache.org/en/js/vendors/echarts/dist/echarts.min.js"></script>
  <script src="https://echarts.apache.org/en/js/vendors/echarts-gl/dist/echarts-gl.min.js"></script>
  <script src="./${USERNAME}Data.js"></script>
  <script src="./${USERNAME}Skyscraper.js"></script>
</body>
</html>
EOL

cat >"statistics/${USERNAME}Skyscraper.js" <<EOL
var dom = document.getElementById('chart-container');
var myChart = echarts.init(dom, null, {
  renderer: 'canvas',
  useDirtyRect: false
});
var app = {};


var option;

// prettier-ignore
var hours = weekNumber;
// prettier-ignore
var days = ['Saturday', 'Friday', 'Thursday',
    'Wednesday', 'Tuesday', 'Monday', 'Sunday'];
// prettier-ignore
var data = dayCommitmentData;

console.log(weekNumber.length)
option = {
  tooltip: {},
  visualMap: {
    max: maxContribution,
    inRange: {
      color: [
        '#313695',
        '#4575b4',
        '#74add1',
        '#abd9e9',
        '#e0f3f8',
        '#ffffbf',
        '#fee090',
        '#fdae61',
        '#f46d43',
        '#d73027',
        '#a50026'
      ]
    }
  },
  xAxis3D: {
    type: 'category',
    data: hours
  },
  yAxis3D: {
    type: 'category',
    data: days
  },
  zAxis3D: {
    type: 'value'
  },
  grid3D: {
    boxWidth: $(( GLOBAL_WEEK_COUNT * 20)),
    boxDepth: 80,
    light: {
      main: {
        intensity: 1.2
      },
      ambient: {
        intensity: 0.3
      }
    }
  },
  series: [
    {
      type: 'bar3D',
      data: data.map(function (item) {
        return {
          value: [item[1], item[0], item[2]]
        };
      }),
      shading: 'color',
      label: {
        show: false,
        fontSize: 16,
        borderWidth: 1
      },
      itemStyle: {
        opacity: 0.4
      },
      emphasis: {
        label: {
          fontSize: 20,
          color: '#900'
        },
        itemStyle: {
          color: '#900'
        }
      }
    }
  ]
};


if (option && typeof option === 'object') {
  myChart.setOption(option);
}

window.addEventListener('resize', myChart.resize);
EOL

cat >"statistics/${USERNAME}Standalone.html" <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>$USERNAME - Skyscraper</title>
  <link rel="stylesheet" href="./style.css">
</head>
<body>
  <div id="chart-container"></div>
  <script src="https://echarts.apache.org/en/js/vendors/echarts/dist/echarts.min.js"></script>
  <script src="https://echarts.apache.org/en/js/vendors/echarts-gl/dist/echarts-gl.min.js"></script>
  <script>
    $(cat "statistics/${USERNAME}Data.js") 
    $(cat "statistics/${USERNAME}Skyscraper.js") 
  </script>
</body>
</html>
EOL

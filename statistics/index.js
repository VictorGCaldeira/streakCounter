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
    boxWidth: 3000,
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

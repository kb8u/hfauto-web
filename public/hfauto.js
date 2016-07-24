google.charts.load('current', {'packages':['gauge']});
google.charts.setOnLoadCallback(drawChart);

var maxPower = 1800;
var powerTicks = ['0','300','600','900','1200','1500','1800'];
var dialWidth = 400;
var dialHeight = 120;

function drawChart() {
  var SWRdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['SWR', 10],
  ]);
  var SWRoptions = {
    width: dialWidth, height: dialHeight,
    min: 1, max: 3,
    minorTicks: 5,
    majorTicks: ['1','1.5','2','2.5','3'],
    greenFrom: 1, greenTo: 1.5,
    yellowFrom: 1.5, yellowTo: 2,
    redFrom: 2, redTo: 6
  };
  var SWRchart = new google.visualization.Gauge(document.getElementById('SWR'));

  var Ldata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Inductance', 137]
  ]);
  var Loptions = {
    width: dialWidth, height: dialHeight,
    min: 137, max: 576,
    minorTicks: 5
  };
  var Lchart = new google.visualization.Gauge(document.getElementById('L'));

  var Cdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Capacitance', 54],
  ]);
  var Coptions = {
    width: dialWidth, height: dialHeight,
    min: 54, max: 203,
    minorTicks: 5
  };
  var Cchart = new google.visualization.Gauge(document.getElementById('C'));

  var Powerdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Power', 0],
  ]);
  var Poweroptions = {
    width: dialWidth, height: dialHeight,
    min: 0, max: maxPower,
    minorTicks: 3,
    majorTicks: powerTicks,
    yellowFrom: 1500, yellowTo: 1800
  };
  var Powerchart = new google.visualization.Gauge(document.getElementById('Power'));

  var PeakPowerdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Power', 0],
  ]);
  var PeakPoweroptions = {
    width: dialWidth, height: dialHeight,
    min: 0, max: maxPower,
    minorTicks: 3,
    majorTicks: powerTicks,
    yellowFrom: 1500, yellowTo: 1800
  };
  var PeakPowerchart = new google.visualization.Gauge(document.getElementById('PeakPower'));

  var websocket = new WebSocket(wsUri);

  setInterval(function() { websocket.send('ping'); }, 9000);

  function updateDials(evt) {
    var j = JSON.parse(evt.data);
    SWRdata.setValue(0, 1, j['ATU_SWR']);
    SWRchart.draw(SWRdata,SWRoptions);
    Ldata.setValue(0, 1, j['ATU_IND']);
    Lchart.draw(Ldata,Loptions);
    Cdata.setValue(0, 1, j['ATU_CAP']);
    Cchart.draw(Cdata,Coptions);
    Powerdata.setValue(0, 1, j['ATU_PWR']);
    Powerchart.draw(Powerdata,Poweroptions);
    PeakPowerdata.setValue(0, 1, j['ATU_PWR_PEAK']);
    PeakPowerchart.draw(PeakPowerdata,PeakPoweroptions);
  };

  websocket.onmessage = function(evt) {
    if (evt.data === 'keep-alive') { return; }
    updateDials(evt);
  };

  websocket.onload = function(evt) {
    updateDials(evt);
  };
}


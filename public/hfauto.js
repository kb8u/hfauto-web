var websocket = new WebSocket(wsUri);

setInterval(function() { websocket.send('ping'); }, 9000);

google.charts.load('current', {'packages':['gauge']});
google.charts.setOnLoadCallback(drawChart);


function drawChart() {
  var SWRdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['SWR', 10],
  ]);
  var SWRoptions = {
    width: 400, height: 120,
    min: 1, max: 3,
    minorTicks: 6,
    greenFrom: 1, greenTo: 1.5,
    yellowFrom: 1.5, yellowTo: 2,
    redFrom: 2, redTo: 6
  };
  var SWRchart = new google.visualization.Gauge(document.getElementById('SWR'));
  SWRchart.draw(SWRdata, SWRoptions);

  var Ldata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Inductance', 137]
  ]);
  var Loptions = {
    width: 400, height: 120,
    min: 137, max: 576,
    minorTicks: 5
  };
  var Lchart = new google.visualization.Gauge(document.getElementById('L'));
  Lchart.draw(Ldata, Loptions);

  var Cdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Capacitance', 54],
  ]);
  var Coptions = {
    width: 400, height: 120,
    min: 54, max: 203,
    minorTicks: 5
  };
  var Cchart = new google.visualization.Gauge(document.getElementById('C'));
  Cchart.draw(Cdata, Coptions);

  websocket.onmessage = function(evt) {
    if (evt.data === 'keep-alive') { return; }
    var j = JSON.parse(evt.data);
    SWRdata.setValue(0, 1, j['ATU_SWR']);
    SWRchart.draw(SWRdata,SWRoptions);
    Ldata.setValue(0, 1, j['ATU_IND']);
    Lchart.draw(Ldata,Loptions);
    Cdata.setValue(0, 1, j['ATU_CAP']);
    Cchart.draw(Cdata,Coptions);
  };
}


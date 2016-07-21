var output;
var websocket = new WebSocket(wsUri);

function init()
{
  output = document.getElementById("output");
  testWebSocket();
}

function testWebSocket()
{
  websocket.onopen = function(evt) { onOpen(evt) };
  websocket.onclose = function(evt) { onClose(evt) };
  websocket.onmessage = function(evt) { onMessage(evt) };
  websocket.onerror = function(evt) { onError(evt) };
}

function onOpen(evt)
{
  writeToScreen("CONNECTED");
  setInterval(doSend, 10000,'keep-alive');
//    doSend("1st data");
}

function onClose(evt)
{
  writeToScreen("DISCONNECTED");
}

function onMessage(evt)
{
  if (evt.data === 'keep-alive') {
    return;
  }
  hfauto = JSON.parse(evt.data);
  ldata.setValue(hfauto['ATU_IND']);
  chart.draw(data, options);
//  writeToScreen('<span style="color: blue;">RESPONSE: ' + evt.data+'</span>');
//  writeToScreen('<span style="color: green;">ATU_IND: ' + hfauto['ATU_IND'] +'</span>');
//  window.scrollTo(0,document.body.scrollHeight);
}

function onError(evt)
{
  writeToScreen('<span style="color: red;">ERROR:</span> ' + evt.data);
}

function doSend(message)
{
  if (websocket.readyState) {
    writeToScreen("SENT: " + message);
    websocket.send(message);
  }
}

function writeToScreen(message)
{
  var pre = document.createElement("p");
  pre.style.wordWrap = "break-word";
  pre.innerHTML = message;
  output.appendChild(pre);
}

window.addEventListener("load", init, false);

//  from https://developers.google.com/chart/interactive/docs/gallery/gauge
google.charts.load('current', {'packages':['gauge']});
google.charts.setOnLoadCallback(drawChart);
function drawChart() {

  var ldata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['Inductance', hfauto['ATU_IND']],
  ]);

  var loptions = {
    width: 400, height: 120,
    max, 255,
    minorTicks: 5
  };

  var chart = new google.visualization.Gauge(document.getElementById('output'));

  chart.draw(ldata, loptions);
}


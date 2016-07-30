(function($, viewport){ $(document).ready(function() {
google.charts.load('current', {'packages':['gauge']});
google.charts.setOnLoadCallback(drawChart);

var highMaxPower = 1800;
var highPowerTicks = ['0','300','600','900','1200','1500','1800'];
var highYellowFrom = 1500;
var lowMaxPower = 120;
var lowPowerTicks = ['0','20','40','60','80','100','120'];
var defaultWidth = 200;
var defaultHeight = 200;

var SWRoptions = {
  width: defaultWidth, height: defaultHeight,
  min: 1, max: 3,
  minorTicks: 5,
  majorTicks: ['1','1.5','2','2.5','3'],
  greenFrom: 1, greenTo: 1.5,
  yellowFrom: 1.5, yellowTo: 2,
  redFrom: 2, redTo: 3
};

var Loptions = {
  width: defaultWidth, height: defaultHeight,
  min: 137, max: 576,
  minorTicks: 5
};

var Coptions = {
  width: defaultWidth, height: defaultHeight,
  min: 54, max: 203,
  minorTicks: 5
};

var Poweroptions = {
  width: defaultWidth, height: defaultHeight,
  min: 0, max: highMaxPower,
  minorTicks: 3,
  majorTicks: highPowerTicks,
  yellowFrom: highYellowFrom, yellowTo: highMaxPower
};

var PeakPoweroptions = {
  width: defaultWidth, height: defaultHeight,
  min: 0, max: highMaxPower,
  minorTicks: 3,
  majorTicks: highPowerTicks,
  yellowFrom: highYellowFrom, yellowTo: highMaxPower
};

function resizeDials(size) {
  SWRoptions['width'] = SWRoptions['height'] = size;
  Loptions['width'] = Loptions['height'] = size;
  Coptions['width'] = Coptions['height'] = size;
  Poweroptions['width'] = Poweroptions['height'] = size;
  PeakPoweroptions['width'] = PeakPoweroptions['height'] = size;
}

function drawChart() {
  var SWRdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['SWR', 10],
  ]);
  var SWRchart = new google.visualization.Gauge(document.getElementById('SWR'));

  var Ldata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['L', 137]
  ]);
  var Lchart = new google.visualization.Gauge(document.getElementById('L'));

  var Cdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['C', 54],
  ]);
  var Cchart = new google.visualization.Gauge(document.getElementById('C'));

  var Powerdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['W', 0],
  ]);
  var Powerchart = new google.visualization.Gauge(document.getElementById('Power'));

  var PeakPowerdata = google.visualization.arrayToDataTable([
    ['Label', 'Value'],
    ['W', 0],
  ]);
  var PeakPowerchart = new google.visualization.Gauge(document.getElementById('PeakPower'));

  var websocket = new WebSocket(wsUri);

  // keep websocket from timing out
  setInterval(function() { websocket.send('ping'); }, 9000);

  function updateDials(j) {
    if(viewport.is('lg')) { resizeDials(200); }
    if(viewport.is('md')) { resizeDials(165); }
    if(viewport.is('<md')) { resizeDials(120); }
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

  function updateText(j) {
    $("#Antenna").html(j['ATU_ANT_NAME']);
    $("#OutputJack").html(j['ATU_ANT_NR']);
    $("#Frequency").html(j['ATU_FREQ']);
    $("#OutputJackMode").html(j['ATU_ANT_SEL_METHOD']);
    $("#TunerMode").html(j['ATU_OPER_MODE']);
  }

  // Execute code each time window size changes
  $(window).resize(
    viewport.changed(function() {
      function changeto(size) {
        resizeDials(size);
        SWRchart.draw(SWRdata,SWRoptions);
        Lchart.draw(Ldata,Loptions);
        Cchart.draw(Cdata,Coptions);
        Powerchart.draw(Powerdata,Poweroptions);
        PeakPowerchart.draw(PeakPowerdata,PeakPoweroptions);
        // add label below dials
        if ($('#SWR>table>tbody>tr:odd').length === 0) {
          $('#SWR>table>tbody>tr').after('<tr><td class="dialText">X:1 ratio</td></tr>');
        }
        if ($('#L>table>tbody>tr:odd').length === 0) {
          $('#L>table>tbody>tr').after('<tr><td class="dialText">Relative Inductance</td></tr>');
        }
        if ($('#C>table>tbody>tr:odd').length === 0) {
          $('#C>table>tbody>tr').after('<tr><td class="dialText">Relative Capacitance</td></tr>');
        }
        if ($('#Power>table>tbody>tr:odd').length === 0) {
          $('#Power>table>tbody>tr').after('<tr><td class="dialText">Average Power</td></tr>');
        }
        if ($('#PeakPower>table>tbody>tr:odd').length === 0) {
          $('#PeakPower>table>tbody>tr').after('<tr><td class="dialText">Peak Power</td></tr>');
        }
      }
      if(viewport.is('lg')) { changeto(200) }
      if(viewport.is('md')) { changeto(165) }
      if(viewport.is('<md')) { changeto(120) }
    })
  );

  websocket.onmessage = function(evt) {
    if (evt.data === 'keep-alive') { return; }
    var j = JSON.parse(evt.data);
    updateDials(j);
    updateText(j);
  };

  websocket.onopen = function(evt) {
    updateDials(evt);
    // add label below dials
    $('#SWR>table>tbody>tr').after('<tr><td class="dialText">X:1 ratio</td></tr>');
    $('#L>table>tbody>tr').after('<tr><td class="dialText">Relative Inductance</td></tr>');
    $('#C>table>tbody>tr').after('<tr><td class="dialText">Relative Capacitance</td></tr>');
    $('#Power>table>tbody>tr').after('<tr><td class="dialText">Average Power</td></tr>');
    $('#PeakPower>table>tbody>tr').after('<tr><td class="dialText">Peak Power</td></tr>');
  };
}
}); })(jQuery, ResponsiveBootstrapToolkit);

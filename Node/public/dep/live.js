
const defaultKey = "40e40966014eb7ac";

const histogramOptions = {
  scales: {
    yAxes: [{
      ticks: {
        beginAtZero: true
      }
    }]
  }
};
const termsOptions = {
  scales: {
    yAxes: [{
      ticks: {
        beginAtZero: true
      }
    }],
    xAxes: [{
      ticks: {
        autoSkip: false
      }
    }]
  }
};

var ctx;

$(document).ready(() => {

  $.get("https://node.hres.ca/_info", (res) => {

    console.log(res);

    res.indices.forEach((index) => {

      var path = index.split("/");

      switch (path[1]) {
        case "nhp":
        case "drug":
          $("#drug_ends").append("<option value='" + index + "'>" + index + "</option>");
          break;
        case "food":
          $("#food_ends").append("<option value='" + index + "'>" + index + "</option>");
          break;
        case "device":
          $("#device_ends").append("<option value='" + index + "'>" + index + "</option>");
          break;
        default:
          $("#other_ends").append("<option value='" + index + "'>" + index + "</option>");
          break;
      }
    })
      .fail((xhr) => {

        console.log(xhr);
      });

    buildQuery();
  });
});

function buildQuery() {

  var query = "https://node.hres.ca";
  query += $("#query-endpoint").val();

  var params = {};
  params.search = $("#query-search").val() != "" ? "search=" + $("#query-search").val() : undefined;
  params.count = $("#query-count").val() != "" ? "count=" + $("#query-count").val() : undefined;
  params.skip = $("#query-skip").val() != "" ? "skip=" + $("#query-skip").val() : undefined;
  params.limit = $("#query-limit").val() != "" ? "limit=" + $("#query-limit").val() : undefined;

  if (params.search || params.count || params.skip || params.limit) {
    query += "?";

    var x = 0;

    for (var p in params) {

      if (params[p]) {
        if (x > 0) {
          query += "&";
        }

        query += params[p];
        x++;
      }
    }
  }

  query = encodeURI(query);

  $("#query").val(query);

  $.get(query + "&key=" + defaultKey, (res) => {

    $("#ctx-open").prop("hidden", true);
    $("#json-response").val(JSON.stringify(res, null, 2));
    if (res.hasOwnProperty("plot")) {
      setChart(res);
    }
  })
    .fail((err) => {

      $("#json-response").val("error");
    });
}

function setChart(rawData) {

  if (ctx) {
    ctx.destroy();
  }

  $("#ctx-open").prop("hidden", false);

  const ctxDiv = document.getElementById('data-chart');
  const data = rawData.plot == "histogram" ? buildHistogramData(rawData.results) : buildTermsData(rawData.results);

  ctx = new Chart(ctxDiv, {
    type: rawData.plot == "histogram" ? "line" : "bar",
    data: data,
    options: rawData.plot == "histogram" ? histogramOptions : termsOptions
  });
}

function buildHistogramData(results) {

  const labels = results.map((result) => {

    const date = new Date(result.key_as_string);
    const month = date.getMonth() + 1;
    const day = date.getDate();

    return date.getFullYear() + "-" + (month < 10 ? "0" + month : month) + "-" + (day < 10 ? "0" + day : day);
  });

  const datasets = [
    {
      label: "Health Canada",
      data: results.map((result) => {
        return result.doc_count
      }),
      borderColor: "#d81200",
      backgroundColor: "rgba(216, 18, 0, 0.4)",
      pointRadius: 5
    }
  ];

  return {
    labels: labels,
    datasets: datasets
  };
}

function buildTermsData(results) {

  const labels = results.map((result) => {
    return result.key
  });

  const datasets = [
    {
      label: "Health Canada",
      data: results.map((result) => {
        return result.doc_count
      }),
      borderWidth: 1,
      borderColor: "#d81200",
      backgroundColor: "rgba(216, 18, 0, 0.4)",
    }
  ];

  return {
    labels: labels,
    datasets: datasets
  };
}

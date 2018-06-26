
let histogramOptions = {
  scales: {
    yAxes: [{
      ticks: {
        beginAtZero: true
      }
    }]
  }
};
let termsOptions = {
  scales: {
    yAxes: [{
      ticks: {
        beginAtZero: true
      }
    }]
  }
};

var ctx;

$(document).ready(() => {

  $.get("http://node.hres.ca/_info", (res) => {

    res.indices.forEach((index) => {

      var path = index.split("/");

      switch (path[1]) {
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
    });
  });

  // resources not loading allow timeout... fix this
  setTimeout(() => {
    buildQuery();
  }, 1000);

});

function getAPIKey() {

  var email = $("#get-key-email").val();

  $.ajaxSetup({
    headers: {
      "X-Key-Gen-Secret": "01MuVFCyvw"
    }
  });

  $.get("https://node.hres.ca/getkey?email=" + email, (res) => {

    $("#new-key-div").html("New API Key: <code>" + res.key + "</code>");
  })
    .fail((error) => {
      $("#new-key-div").html("<code>API key error</code>");
    });
}

function retrieveAPIKey() {

  var email = $("#retrieve-key-email").val();
  console.log(email);

  $("#retrieve-key-div").html("Your API Key has been emailed to you.");
}

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

  $.get(query, (res) => {

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

  let ctxDiv = document.getElementById('data-chart');
  let data = rawData.plot == "histogram" ? buildHistogramData(rawData.results) : buildTermsData(rawData.results);

  ctx = new Chart(ctxDiv, {
    type: rawData.plot == "histogram" ? "line" : "bar",
    data: data,
    options: rawData.plot == "histogram" ? histogramOptions : termsOptions
  });
}

function buildHistogramData(results) {

  let labels = results.map((result) => {
    return result.key_as_string
  });

  let datasets = [
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

  let labels = results.map((result) => {
    return result.key
  });

  let datasets = [
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


$(document).ready(() => {

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

  var query = "https://node.hres.ca/";
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

    $("#json-response").val(JSON.stringify(res, null, 2));
    setChart(res);
  })
    .fail((err) => {

      $("#json-response").val("error");
    });
}

function setChart(rawData) {}

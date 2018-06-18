
function getAPIKey() {

  var email = $("#get-key-email").val();
  console.log(email);

  $.ajaxSetup({
    headers: {
      "X-Key-Gen-Secret": "01MuVFCyvw"
    }
  });

  $.get("https://node.hres.ca/key?email=" + email, (res) => {

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

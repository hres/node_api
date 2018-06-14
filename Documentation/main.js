
function getAPIKey() {

  var email = $("#get-key-email").val();
  console.log(email);

  $("#new-key-div").prop("hidden", false);

  $.get("https://node.hres.ca/key?email=" + email, (res) => {

    $("#new-api-key").html(res.key);
  })
    .fail((error) => {
      $("#new-api-key").html("API key error");
    });
}

function retrieveAPIKey() {

  var email = $("#retrieve-key-email").val();
  console.log(email);

  $("#retrieve-key-div").prop("hidden", false);
}

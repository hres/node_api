
// TODO: implement getAPIKey and manageAPIKeys
// TODO: implement forgot passowrd link

function getAPIKey() {

  window.open("https://node.hres.ca/new.html", "_blank");
};

function manageAPIKeys() {

  const email = $("#manage-keys-email").val();

  if (email.indexOf("@") > -1) {
    window.open("https://node.hres.ca/manage.html?ea=" + encodeURIComponent(email), "_blank");
  }
  else {
    $("#manage-keys-email").val("");
  }
};

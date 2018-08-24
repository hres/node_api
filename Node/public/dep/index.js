
// TODO: implement getAPIKey and manageAPIKeys
// TODO: implement forgot passowrd link

function getAPIKey() {

  window.open("https://node.hres.ca/new.html", "_blank");
};

function manageAPIKeys() {

  const email = $("#manage-keys-email").val();
  const password = $("#manage-keys-password").val()

  console.log("email: " + email);
  console.log("password: " + password);
  console.log("501: Not Implemented.");
};

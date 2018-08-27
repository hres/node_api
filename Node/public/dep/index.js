
// TODO: implement getAPIKey and manageAPIKeys
// TODO: implement forgot passowrd link

function getAPIKey() {

  window.open("https://node.hres.ca/new.html", "_blank");
};

function manageAPIKeys() {

  const email = $("#manage-keys-email").val();
  const password = $("#manage-keys-password").val();

  var data = {
    email: email,
    password: password
  };

  $.post("https://node.hres.ca/getuser", data, (res) => {
    console.log("email: " + email);
    console.log("password: " + password);
    console.log(res);
    window.alert(JSON.stringify(res, null, 2));
  })
    .fail((xhr) => {
      console.log(xhr);
      window.alert(xhr);
    });
};

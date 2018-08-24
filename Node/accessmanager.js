
// Bimal Bhagrath
// MODULE : api key manager

const { pg } = require('pg');
const crypto = require('crypto');

var pgClient = new pg();

exports.newAccount = async (email, password) => {

  const key = crypto.randomBytes(12).toString('hex');

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];

  try {
    await pgClient.connect();

    let users = await pgClient.query(userQuery, userValues);

    console.log(users);

    return true;
  }
  catch (err) {
    throw err;
  }
};

exports.verifyKey = (key) => {

  return true;
};

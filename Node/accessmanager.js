
// Bimal Bhagrath
// MODULE : api key manager

const { Pool } = require('pg');
const crypto = require('crypto');

var pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "api_admin",
  password: "",
  port: 5432
});

exports.newAccount = async (email, password) => {

  const key = crypto.randomBytes(12).toString('hex');

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];

  try {
    await pool.connect();

    let users = await pool.query(userQuery, userValues);

    console.log(users);

    await pool.end();

    return true;
  }
  catch (err) {
    throw err;
  }
};

exports.verifyKey = (key) => {

  return true;
};

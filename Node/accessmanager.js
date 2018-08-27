
// Bimal Bhagrath
// MODULE : api key manager

const { Pool } = require('pg');
const crypto = require('crypto');

var pool = new Pool({
  user: "manager",
  host: "localhost",
  database: "api_admin",
  password: "api_manager",
  port: 5432
});

pool.connect();

exports.newAccount = async (email, password) => {

  const salt = crypto.randomBytes(8).toString('hex');
  const pass = crypto.createHash('sha256').update(password + salt).digest('hex');
  const key = crypto.randomBytes(8).toString('hex');

  const time = new Date();

  const pgDate = time.getFullYear() + "-" + (time.getMonth() < 9 ? "0" + (time.getMonth() + 1) : (time.getMonth() + 1)) + "-" + time.getDate();

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];
  const insertUserQuery = "INSERT INTO users(user_email, salt, password, sign_up_date) VALUES($1, $2, $3, $4)";
  const insertUserValues = [email, salt, pass, pgDate];
  const insertKeyQuery = "INSERT INTO api_keys(user_email, key) VALUES($1, $2)";
  const insertKeyValues = [email, key];

  try {
    var users = await pool.query(userQuery, userValues);

    if (users.rows.length < 1) {
        var insertUser = await pool.query(insertUserQuery, insertUserValues);
        var insertKey = await pool.query(insertKeyQuery, insertKeyValues);

        return {
          user_email: email,
          api_key: key
        };
    }

    throw "email already in use";
  }
  catch (err) {
    throw err;
  }
};

exports.verifyKey = async (key) => {

  const verifyQuery = "SELECT * FROM api_keys WHERE key = $1";
  const verifyValues = [key];

  try {
    var res = await pool.query(verifyQuery, verifyValues);
     if (res.rows.length > 0) {
       return true;
     }

     return false;
  }
  catch (err) {
    return false;
  }
};

exports.getAccount = async (email, password) => {

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];
  const accountQuery = "SELECT * FROM api_keys WHERE user_email = $1";

  try {
    var users = await pool.query(userQuery, userValues);

    if (users.rows.length > 0) {
      const user = users.rows[0];
      const pass = crypto.createHash('sha256').update(password + user.salt).digest('hex');

      if (pass === user.password) {
        var account = await pool.query(accountQuery, userValues);

        return account.rows;
      }
      else {
        throw "invalid credentials";
      }
    }
    else {
      throw "user not found";
    }
  }
  catch (err) {
    throw err;
  }
};

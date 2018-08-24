
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

exports.newAccount = async (email, password) => {

  const salt = crypto.randomBytes(8).toString('hex');
  const pass = crypto.createHash('sha256').update(password + salt).digest('hex');

  const time = new Date();

  const pgDate = time.getFullYear() + "-" + (time.getMonth() < 9 ? "0" + (time.getMonth() + 1) : (time.getMonth() + 1)) + "-" + time.getDate();

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];
  const insertUserQuery = "INSERT INTO users(user_email, salt, password, sign_up_date) VALUES($1, $2, $3, $4)";
  const insertUserValues = [email, salt, pass, pgDate];
  const insertKeyQuery = "INSERT INTO api_keys(user_email, key) VALUES($1, $2)";

  try {
    await pool.connect();
    var users = await pool.query(userQuery, userValues);

    if (users.rows.length < 1) {
        var success = false;
        var key;

        var insertUser = await pool.query(insertUserQuery, insertUserValues);

        while (!success) {
          key = crypto.randomBytes(8).toString('hex');
          const insertKeyValues = [email, key];

          try {
             var insertKey = await pool.query(insertKeyQuery, insertKeyValues);
             success = true;
          }
          catch (err) {
            success = false;
          }
        }

        await pool.end();
        return {
          user_email: email,
          api_key: key
        };
    }

    await pool.end();
    throw "email already in use";
  }
  catch (err) {
    await pool.end();
    throw err;
  }
};

exports.verifyKey = (key) => {

  return true;
};

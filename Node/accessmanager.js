
// Bimal Bhagrath
// MODULE : api key manager

const { Pool } = require('pg');
const crypto = require('crypto');
const ipRangeCheck = require('ip-range-check');

const ipWhitelist = [
  // HRE whitelist
  "192.168.0.0/16",
  "172.16.0.0/12",
  "10.0.0.0/8",
  // GOV
  "65.93.227.0/24",
  "65.93.228.0/24",
  "67.210.160.2/32",
  "70.38.76.193/32",
  "70.38.76.194/31",
  "70.38.71.204/32",
  "131.134.0.0/15",
  "131.136.0.0/14",
  "131.140.0.0/15",
  "132.156.0.0/16",
  "132.246.0.0/16",
  "142.78.0.0/16",
  "142.176.61.145/32",
  "142.206.0.0/16",
  "167.32.0.0/15",
  "167.37.0.0/16",
  "192.75.14.0/24",
  "192.139.116.0/24",
  "192.197.67.0/24",
  "192.197.68.0/22",
  "192.197.72.0/21",
  "192.197.80.0/22",
  "192.197.84.0/23",
  "192.197.86.0/24",
  "192.197.178.0/24",
  "198.103.0.0/16",
  "198.164.40.0/23",
  "199.212.16.0/22",
  "199.212.20.0/23",
  "199.212.148.0/22",
  "199.212.215.0/24",
  "204.174.103.0/24",
  "205.192.0.0/15",
  "205.194.0.0/16",
  "207.61.156.0/22",
  "216.208.251.0/24"
];

var pool = new Pool({
  user: "manager",
  host: "localhost",
  database: "api_admin",
  password: "api_manager",
  port: 5432
});

pool.connect();

exports.newAccount = async (email) => {

  const key = crypto.randomBytes(8).toString('hex');
  const time = new Date();
  const pgDate = time.getFullYear() + "-" + (time.getMonth() < 9 ? "0" + (time.getMonth() + 1) : (time.getMonth() + 1)) + "-" + time.getDate();

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];
  const insertUserQuery = "INSERT INTO users(user_email, sign_up_date) VALUES($1, $2)";
  const insertUserValues = [email, pgDate];
  const insertKeyQuery = "INSERT INTO api_keys(user_email, key, status) VALUES($1, $2, $3)";
  const insertKeyValues = [email, key, true];

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

    if (res.rows.length > 1) {
      return res.rows[0].status;
    }

    return false;
  }
  catch (err) {
    return false;
  }
};

exports.getAccount = async (email) => {

  const userQuery = "SELECT * FROM users WHERE user_email = $1";
  const userValues = [email];
  const accountQuery = "SELECT * FROM api_keys WHERE user_email = $1";

  try {
    var users = await pool.query(userQuery, userValues);

    if (users.rows.length == 1) {
      const user = users.rows[0];
      const accountValues = [user.user_email];

      var account = await pool.query(accountQuery, accountValues);

      return {
        user: user,
        keys: account.rows.map((row) => {

          return {
            key: row.key,
            status: row.status
          }
        })
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

exports.addKey = async (email) => {

  const keyQuery = "";
  const keyValues = [email];

  try {
    var keys = await pool.query(keyQuery, keyValues);

    console.log(keys);

    return true;
  }
  catch (err) {
    throw err;
  }
};

exports.revokeKey = async (email, key) => {

  const revokeQuery = "UPDATE api_keys SET status = false WHERE user_email = $1 AND key = $2";
  const revokeValues = [email, key];

  try {
    await pool.query(revokeQuery, revokeValues);

    return true;
  }
  catch (err) {
    throw err;
  }
};

exports.whitelist = (ip) => {

  return ipRangeCheck(ip, ipWhitelist);
};

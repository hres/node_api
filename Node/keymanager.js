
// Bimal Bhagrath
// MODULE : api key manager

const crypto = require('crypto');

exports.generateAPIKey = () => {

  return crypto.randomBytes(12).toString('hex');
};

exports.set = (key, email) => {

  const time = new Date();
  console.log("inserted key: " + key + " for email: " + email + " at " + time.toISOString());
};

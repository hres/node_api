
// Bimal Bhagrath
// MODULE : api key management

const crypto = require('crypto');

module.exports.generateAPIKey = () => {

  return crypto.randomBytes(12).toString('hex');
}

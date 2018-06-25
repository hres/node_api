
// Bimal Bhagrath
// CONFIG : move environment variables to process.env for production

module.exports = {
  "API_VERSION": "v1.1.0",
  "API_LOCAL": "http://localhost:3000",
  "API_HTTPS": "https://node.hres.ca",
  "API_PORT": 3000,
  "ELASTIC_HOST": "http://elastic-gate.hc.local:80",
  "ELASTIC_PORT": 80,
  "ELASTIC_LOG": {
    type: "file",
    level: "error",
    path: "./esclient.log"
  },
  "KEY_GEN_SECRET": "01MuVFCyvw",
  "RESPONSE_META_DATA": {
    disclaimer: "",
    terms_of_use: "",
    license: "",
    date_updated: "2018-06-18"
  }
};

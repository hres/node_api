
// Bimal Bhagrath
// CONFIG : move environment variables to process.env for production

// running server requires PM2 node process manager module
// npm install pm2 -g

// starting server
// pm2 start index.js -i max

// stop server
// pm2 stop all

// restart server and implement modifications
// pm2 restart all

// running on boot of linux system
// pm2 startup systemd

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
  "LOGS": {
    "INFO_FILE": "/public/logs/info.log",
    "ERR_FILE": "/public/logs/err.log"
  },
  "KEY_GEN_SECRET": "01MuVFCyvw",
  "RESPONSE_META_DATA": {
    disclaimer: "",
    terms_of_use: "",
    license: "",
    date_updated: "2018-06-18"
  }
};

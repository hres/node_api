
// Bimal Bhagrath
// API entry point

const express = require('express');
const parser = require('body-parser');
const es = require('elasticsearch');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const c = require('./config');
const esroutes = require('./esroutes');
const esquery = require('./esquery');
const accessManager = require('./accessmanager');

const demoQuery = {
  key: "test"
};

var api = express();

api.use(parser.urlencoded({
  extended: true
}));
api.use(parser.json());

var esclient = new es.Client({
  host: c.ELASTIC_HOST,
  log: c.ELASTIC_LOG,
  requestTimeout: 10000
});

api.listen(c.API_PORT, () => {

  console.log("listening on '" + c.API_LOCAL + "' or '" + c.API_HTTPS + "'");
});

api.use((req, res, next) => {

    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "X-Key-Gen-Secret");
    next();
});
api.use(express.static(path.join(__dirname, "public")));

const infoLogStream = fs.createWriteStream(path.join(__dirname, "public", "logs", "info.log"), {
  flags: "a"
});
const errLogStream = fs.createWriteStream(path.join(__dirname, "public", "logs", "err.log"), {
  flags: "a"
});

api.use(morgan('combined', {
    skip: (req, res) => {
        return res.statusCode < 400
    },
    stream: errLogStream
}));
api.use(morgan('combined', {
    skip: (req, res) => {
        return res.statusCode >= 400
    },
    stream: infoLogStream
}));

api.set("json spaces", 2);

api.post('/account', async (req, res) => {

  if (req.headers["x-key-gen-secret"] === c.KEY_GEN_SECRET && req.body.email) {
    try {
      const account = await accessManager.newAccount(req.body.email);

      res.status(201).json(account);
    }
    catch (err) {
      res.status(409).json(err);
    }
  }
  else {
    res.status(400).json({
      error: "invalid request"
    });
  }
});

//api.post('/forgotpassword', (req, res) => {});

api.post('/getuser', async (req, res) => {

  if (req.body.hasOwnProperty("email")) {
    try {
      var account = await accessManager.getAccount(req.body.email);

      res.status(200).json(account);
    }
    catch (err) {
      res.status(500).json(err);
    }
  }
  else {
    res.status(400).json({
      error: "bad request"
    });
  }
});

api.post('/addkey', async (req, res) => {

  if (req.body.hasOwnProperty("email")) {
    try {
      var newKey = await accessManager.addKey(req.body.email);

      res.status(201).json({
        email: req.body.email,
        added: newKey
      });
    }
    catch (err) {
      res.status(500).json(err);
    }
  }
  else {
    res.status(400).json({
      error: "bad request"
    });
  }
});

api.post('/revokekey', async (req, res) => {

  if (req.body.hasOwnProperty("email") && req.body.hasOwnProperty("key")) {
    try {
      var revoked = await accessManager.revokeKey(req.body.email, req.body.key);

      res.status(200).json({
        revoked: revoked
      });
    }
    catch (err) {
      res.status(500).json(err);
    }
  }
  else {
    res.status(400).json({
      error: "bad request"
    });
  }
});

// get info about endpoints and log files
api.get('/_info', (req, res) => {

  const indices = esroutes.ENDPOINTS.map((endpoint) => {
    return endpoint.API_ENDPOINT;
  });

  // move log info to GET /statistics route
  const logs = {
    info: c.LOGS.INFO_FILE,
    error: c.LOGS.ERR_FILE
  }

  return res.status(200).json({
    indices: indices,
    logs: logs
  });
});

/*
api.get('/statistics', (req, res) => {

  res.status(200).json({});
});
*/

// require API key beyond this middleware
api.use((req, res, next) => {

  console.log(await accessManager.verifyKey(req.query.key));

  if (req.query.hasOwnProperty("key")) {
    if (req.query.key == "test") {
      next();
    }
    else {
      var pass = await accessManager.verifyKey(req.query.key);

      if (pass) {
        next();
      }
      else {
        res.status(401).json({
          error: "invalid api key"
        });
      }
    }
  }
  else if (accessManager.whitelist(req.headers["x-real-ip"])) {
    next();
  }
  else {
    res.status(401).json({
      error: "invalid api key"
    });
  }
});

// format ElasticSearch JSON response
function includeElasticResult(esres) {

  const stripped = esquery.strip(esres);

  return {
    meta: c.RESPONSE_META_DATA,
    total: stripped.total,
    plot: stripped.hasOwnProperty("plot") ? stripped.plot : undefined,
    results: stripped.results
  };
}

// dynamic router creation for all data endpoints
var createRouter = (endpoint) => {

  var route = endpoint.API_ENDPOINT;
  var index = endpoint.ES_INDEX;

  api.get(route, async (req, res) => {

    if (req.query.key == "test") {
      req.query = demoQuery;
    }

    try {
      esquery.validate(req.query);
      var esbody = esquery.build(req.query);

      var esres = await esclient.search({
        index: index,
        body: esbody
      });

      var data = includeElasticResult(esres);

      res.status(200).json(data);
    }
    catch (err) {
      if (err.hasOwnProperty("status")) {
        res.status(err.status).json(err);
      }
      else {
        res.status(500).json(err);
      }
    }
  });
};

// generate router
esroutes.ENDPOINTS.forEach((endpoint) => {

  createRouter(endpoint);
});

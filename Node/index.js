
// Bimal Bhagrath
// API entry point

const express = require('express');
const parser = require('body-parser');
const es = require('elasticsearch');
const morgan = require('morgan');
const fs = require('fs');
const c = require('./config');
const esroutes = require('./esroutes');
const esquery = require('./esquery');
const logger = require('./logger');
const keymanager = require('./keymanager');

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
api.use(express.static("public"));
api.use(morgan('combined', {
    skip: (req, res) => {
        return res.statusCode < 400
    },
    stream: fs.createWriteStream(c.LOGS.ERR_FILE)
}));
app.use(morgan('combined', {
    skip: (req, res) => {
        return res.statusCode >= 400
    },
    stream: fs.createWriteStream(c.LOGS.INFO_FILE)
}));

api.set("json spaces", 2);

api.get('/getkey', (req, res) => {

  if (req.headers.hasOwnProperty("x-key-gen-secret") && req.headers["x-key-gen-secret"] === c.KEY_GEN_SECRET && req.query.hasOwnProperty("email")) {
    const apiKey = keymanager.generateAPIKey();
    keymanager.set(apiKey, req.query.email);

    res.status(201).json({
      key: apiKey
    });
  }
  else {
    res.status(400).json({
      error: "unable to generate api key"
    });
  }
});

//api.post('/lostkey', (req, res) => {});

// restrict to no public access
api.get('/statistics', (req, res) => {

  // include actual statistics from logs
  res.status(200).json({
    datasets: {
      drugs: {},
      foods: {},
      devices: {},
      other: {}
    },
    api_calls: {
      time: [0],
      drugs: 0,
      foods: 0,
      devices: 0,
      other: 0
    }
  });
});

api.get('/_info', (req, res) => {

  // restrict which fields can be aggregated on and list them to return

  const indices = esroutes.ENDPOINTS.map((endpoint) => {
    return endpoint.API_ENDPOINT;
  });

  const logs = {
    info: c.LOGS.INFO_FILE,
    error: c.LOGS.ERR_FILE
  }

  return res.status(200).json({
    indices: indices,
    logs: logs
  });
});

function includeElasticResult(esres) {

  const stripped = esquery.strip(esres);

  return {
    meta: c.RESPONSE_META_DATA,
    total: stripped.total,
    plot: stripped.hasOwnProperty("plot") ? stripped.plot : undefined,
    results: stripped.results
  };
}

//var createLanding = (landing) => {};

var createLinearRoute = (endpoint) => {

  var route = endpoint.API_ENDPOINT;
  var index = endpoint.ES_INDEX;

  api.get(route, async (req, res) => {

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

// create dynamic landings for all defined landings in esroutes.js configuration
/*
esroutes.LANDINGS.forEach((landing) => {

  createLanding(landing);
});
*/

// create dynamic endpoints for all defined endpoints in esroutes.js configuration
esroutes.ENDPOINTS.forEach((endpoint) => {

  createLinearRoute(endpoint);
});

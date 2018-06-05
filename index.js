
// Bimal Bhagrath
// API entry point

const express = require('express');
const parser = require('body-parser');
const es = require('elasticsearch');
const c = require('./config');
const esroutes = require('./esroutes');
const esquery = require('./esquery');
const keymanager = require('./keymanager');

// RESULT HANDLING
/*
const META_BLOCK = {};
*/

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
  console.log(keymanager.generateAPIKey());
});

api.use((req, res, next) => {

    res.header("Access-Control-Allow-Origin", "*");
    next();
});

api.set("json spaces", 2);

api.get('/', (req, res) => {

  res.status(200).send("Hello, Welcome to Health Canada APIs (" + c.API_VERSION + ")");
});

// RESULT HANDLING
/*
function includeElasticResult(esres) {

  return {
    meta: META_BLOCK,
    total: esres.hasOwnProperty("hits") && esres.hits.hasOwnProperty("total") ? esres.hits.total : undefined,
    results: esquery.strip(esres)
  };
}
*/

//var createLanding = (landing) => {};

var createRoute = (endpoint) => {

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

      // RESULT HANDLING
      /*
      var data = includeElasticResult(esres);
      */

      res.status(200).json(esres);
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

  createRoute(endpoint);
});

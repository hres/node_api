
// Bimal Bhagrath
// API entry point

const express = require('express');
const parser = require('body-parser');
const es = require('elasticsearch');
const c = require('./config');
const esroutes = require('./esroutes');
const esquery = require('./esquery');

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
    next();
});

api.set("json spaces", 2);

api.get('/' (req, res) => {

  res.send(200, "Hello, Welcome to Health Canada APIs (" + c.API_VERSION + ")");
});

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

esroutes.ENDPOINTS.forEach((endpoint) => {

  createRoute(endpoint);
});

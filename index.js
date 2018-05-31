
// Bimal Bhagrath

// API entry point

const express = require('express');
const parser = require('body-parser');
const es = require('elasticsearch');
const c = require('./config');
const esroutes = require(',.esroutes');
const esquery = require('./esquery');

// API SETUP
var api = express();

api.use(bodyParser.urlencoded({
  extended: true
}));
api.use(bodyParser.json());

// connect to ElasticSearch
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

// API ROUTER
var createRoute = (endpoint) => {

  var route = endpoint.API_ENDPOINT;
  var index = endpoint.ES_INDEX;

  api.get(route, async (req, res) => {

    if (esquery.validateQuery(req.query)) {
      console.log(req.query);
    }
    else {
      res.status(400).json({
        location: route,
        message: "request contains unexpected or incorrect parameters"
      });
    }

    esclient.close();
  });
};

esroutes.forEach((endpoint) => {
  createRoute(endpoint);
});

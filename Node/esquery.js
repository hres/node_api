
// Bimal Bhagrath
// MODULE : elasticsearch query manager

const builder = require('elastic-builder');

const QS_LIST = [
  "search",
  "count",
  "skip",
  "limit",
  "key"
];
const HISTOGRAM_FIELDS = [
  "datintreceived",
  "datreceived",
  "status_cancelled_postmarket_date",
  "status_detail.history_date",
  "status_detail.original_market_date",
  "status_approved_date",
  "last_refresh",
  "licence_date"
];
const HISTOGRAM_INTERVALS = [
  "year",
  "quarter",
  "month",
  "week",
  "day"
];
const DEFAULT_HISTOGRAM_INTERVAL = "day";
const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 1000;
const HISTOGRAM_AGGREGATION_NAME = "intervals";
const TERMS_AGGREGATION_NAME = "terms";

exports.validate = (query) => {

  for (var param in query) {
     if (!QS_LIST.includes(param)) {
       throw {
         error: "query validation",
         status: 400,
         message: "request contains unexpected paramater: " + param
       };
     }
  }

  if (query.hasOwnProperty("skip")) {
    var skip = parseInt(query.skip);

    if (isNaN(skip) || skip < 0) {
      throw {
        error: "query validation",
        status: 400,
        message: "invalid skip value"
      };
    }
  }

  if (query.hasOwnProperty("limit")) {
    var limit = parseInt(query.limit);

    if (isNaN(limit) || limit < 0) {
      throw {
        error: "query validation",
        status: 400,
        message: "invalid limit value"
      };
    }
  }
};

exports.build = (query) => {

  var esbody = builder.requestBodySearch();

  if (!query.hasOwnProperty("search") && !query.hasOwnProperty("count")) {
    esbody.query(builder.matchAllQuery());
  }

  if (query.hasOwnProperty("search")) {
    esbody.query(builder.queryStringQuery(query.search));
  }

  if (query.hasOwnProperty("count")) {
    var params = (query.count).split(":");

    if (HISTOGRAM_FIELDS.includes(params[0])) {
      var interval;

      if (params.length > 1) {
        interval = HISTOGRAM_INTERVALS.includes(params[1]) ? params[1] : DEFAULT_HISTOGRAM_INTERVAL;
      }
      else {
        interval = DEFAULT_HISTOGRAM_INTERVAL;
      }

      esbody.agg(builder.dateHistogramAggregation(HISTOGRAM_AGGREGATION_NAME, params[0], interval));
    }
    else {
      //var limit = query.hasOwnProperty("limit") && query.limit < MAX_LIMIT ? query.limit : MAX_LIMIT;

      esbody.agg(builder.termsAggregation(TERMS_AGGREGATION_NAME, params[0]).size(query.limit));
    }

    esbody.size(0);
  }

  if (query.hasOwnProperty("skip") && !query.hasOwnProperty("count")) {
    var skip = parseInt(query.skip);
    esbody.from(skip);
  }

  if (query.hasOwnProperty("limit") && !query.hasOwnProperty("count")) {
    var limit = parseInt(query.limit);

    if (limit > MAX_LIMIT) {
      esbody.size(MAX_LIMIT);
    }
    else {
      esbody.size(limit);
    }
  }

  return esbody.toJSON();
};

exports.strip = (body) => {

  var response = {};

  response.total = body.hasOwnProperty("hits") && body.hits.hasOwnProperty("total") ? body.hits.total : 0

  if (body.hasOwnProperty("aggregations")) {
    if (body.aggregations.hasOwnProperty(HISTOGRAM_AGGREGATION_NAME)) {
      response.plot = "histogram";
      response.results = body.aggregations[HISTOGRAM_AGGREGATION_NAME]["buckets"];
    }
    else if (body.aggregations.hasOwnProperty(TERMS_AGGREGATION_NAME)) {
      response.plot = "terms";
      response.results = body.aggregations[TERMS_AGGREGATION_NAME]["buckets"];
    }
  }
  else if (body.hasOwnProperty("hits")) {
    response.results = body.hits.hits
  }
  else {
    response.results = [];
  }

  return response;
};

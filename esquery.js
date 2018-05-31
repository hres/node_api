
// Bimal Bhagrath

// MODULE : elasticsearch query manager

const builder = require('elastic-builder');

const VALID_QS_PARAMS = ["search", "count", "skip", "limit"];

exports.validateQuery = (query) => { // expects express req.query

  if (query === undefined || query === null) return false;

  for (var param in query) {
     if (!VALID_QS_PARAMS.includes(param)) return false;
  }

  if (query.hasOwnProperty("skip") {
    var skip = parseInt(query.skip);

    if (isNaN(skip)) return false;
  }

  if (query.hasOwnProperty("limit") {
    var limit = parseInt(query.limit);

    if (isNaN(limit)) return false;
  }

  return true;
};

exports.buildQuery = (query) => { // expects express req.query

  if (query.hasOwnProperty("search")) {}
};

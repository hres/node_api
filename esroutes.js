
// Bimal Bhagrath
// MODULE : express endpoint schema for elasticsearch

module.exports = {
  "ENDPOINTS": [
    {
      "API_ENDPOINT": "/drug/event",
      "ES_INDEX": "drug_event*"
    },
    {
      "API_ENDPOINT": "/drug/noc",
      "ES_INDEX": "noc_onl_test"
    }
  ],
  "LANDINGS": [
    {
      "API_LANDING": "/drug"
    }
  ]
}

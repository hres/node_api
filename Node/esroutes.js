
// Bimal Bhagrath
// MODULE : express endpoint schema for elasticsearch

module.exports = {
  "ENDPOINTS": [
    {
      "API_ENDPOINT": "/drug/event",
      "ES_INDEX": "drug_event*"
    },
    {
      "API_ENDPOINT": "/drug/event2",
      "ES_INDEX": "an_index"
    }
  ],
  "LANDINGS": [
    {
      "API_LANDING": "/drug"
    }
  ]
}

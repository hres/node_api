
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
      "ES_INDEX": "an_index2"
    },
    {
      "API_ENDPOINT": "/drug/event3",
      "ES_INDEX": "drug_event_unnested"
    }
  ],
  "LANDINGS": [
    {
      "API_LANDING": "/drug"
    },
    {
      "API_LANDING": "/food"
    },
    {
      "API_LANDING": "/device"
    }
  ]
}


// Bimal Bhagrath
// MODULE : express endpoint schema for elasticsearch

module.exports = {
  "ENDPOINTS": [
    {
      "API_ENDPOINT": "/drug/event",
      "ES_INDEX": "drug_event"
    },
    {
      "API_ENDPOINT": "/drug/product",
      "ES_INDEX": "dpd_drug"
    },
    {
      "API_ENDPOINT": "/nhp/product",
      "ES_INDEX": "lnhpd"
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

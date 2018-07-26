
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
    },
    {
      "API_ENDPOINT": "/drug/event4",
      "ES_INDEX": "cv_report_nested_arrays"
    },
    {
      "API_ENDPOINT": "/drug/event5",
      "ES_INDEX": "cv_reports_arrays_july_24"
    },
    {
      "API_ENDPOINT": "/drug/event6",
      "ES_INDEX": "cv_reports_arrays_july_26"
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

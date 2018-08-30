{
  "apps" : [{
    // Application #1
    "name"        : "node-api",
    "script"      : "index.js",
    "watch"       : true,
    "merge_logs"  : true,
    "cwd"         : "/",
    "env": {
      "DB": "api_admin",
      "DB_USER": "manager",
      "DB_PASS": "api_manager"
    },
    "env_production" : {}
  }]
}

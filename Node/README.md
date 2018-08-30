# NodeJS API
NodeJS is a JavaScript runtime environment. In the case of Health Canada APIs Node was used to create a server that responds to HTTP requests that are stateless. This is a public facing wrapper around ElasticSearch which can be queried by passing Lucene Query Syntax strings as parameters to the respective endpoints. This README file contains information on how to read and update the source code. For documentation on how to pass requests to the server please view the documentation page in the public folder. 

This README file was last updated on 2018-08-31.

## Environment Setup
Check your version of Node and npm using `node -v` and `npm -v `. To update npm run `sudo npm install -g npm` (currently using v6.4.0).

To start the node process in dev mode run the index.js file with command `node index`.

To start in production mode, use process manager PM2 as follows:
```bash
# install PM2
npm install pm2

# start the node server
pm2 start index.js -i max

# restart the server implement changes
pm2 restart all

# stop the server
pm2 stop all

# daemon start server on Ubuntu
pm2 startup systemd
```

## Directories
In the root directory (parent to this directory) the node config file and modules directory can be found. `package.json` contains the packages installed as well as their versions while `node_modules` contains their source code.

To update all packages run command `npm update -g`

## Dependencies
- body-parser `1.18.3` [used to parse and expose req.body, req.query and req.params from the HTTP request]
- elastic-builder `1.3.0` [used to build ElasticSearch queries (Kibana console syntax)]
- elasticsearch `15.1.1` [interface to connect to ElasticSearch]
- express `4.16.3` [API framework]
- ip-range-check `0.0.2` [used for access control]
- morgan `1.9.0` [used to format logs and create write streams for info vs err]

## Maintenance

### config.js
Environment variables are in this file, consider passing protected information (passwords, api keys...) to `process.env` for production

### Adding and deleting routes
To add or delete a route (i.e. /drug/route) 2 changes need to be made. In the esroutes.js file modify the default exports "ENDPOINTS" array. Each route is represented by an object as follows:
```text
{
  "API_ENDPOINT: "/landing/endpoint", // part of the HTTP request
  "ES_INDEX": "elasticsearch_index" // the ElasticSeach index the corresponds to that endpoint
}
```
All count aggregations default to term aggregations, if the field requires histogram aggregation you must specify the fields in the esquery.js file and append the field name to the "HISTOGRAM_FIELDS" array.

### Access control
To configure the IP address whitelist for users to gain access without API Keys, modify the ipWhitelist array declared in the accessmanager.js module 

## Updating
To add features and tweak this API, please fork the repository and refer to the comments in the code to guide you.

## Logging
Logs are being output to `/public/info.log` and `/public/err.log`. These files are exposed publically on express.static, to make to remove them form express.static, move them out of the `/public` directory and configure the morgan middleware accordingly.

## /public
All files in this directory are exposed on express.static as a static web server. Add any static webpages and files you want in this directory to be served from the API.

## API Keys
API keys are required with the following structure. Testing IP addresses against a whitelist will lead to higher latency therefore including an API key leads to better response time. The middleware first checks if a key is present, if so, use the key and authenticate, if no key is present then check the IP adddess against the whitelist. 

API key management pages at `/public/manage.html` and `/public/new.html` are an interface to call API Key routes. Should anything go wrong, you can stop the API key requirement and allow all calls to go through by commenting out the middleware `api.use` function indicated under the "require API Keys beyond this point" comment.

### Database Schema
```bash
CREATE TABLE users (
  user_email varchar(256) PRIMARY KEY,
  #salt varchar(32) NOT NULL,
  #password text NOT NULL,
  sign_up_date date NOT NULL
);

CREATE TABLE api_keys (
  user_email varchar(256) REFERENCES users (user_email),
  key varchar(32) UNIQUE
);
```


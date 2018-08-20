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
- morgan `1.9.0` [used to format logs and create write streams for info vs err]


const express = require('express');
const bodyParser = require('body-parser');
const routes = require('./routes');
const { HOST, EXPRESS_PORT } = require('./config');
const webserver = require('./websocket');

const app = express();
app.use(bodyParser.json());
app.use(routes);

app.listen(EXPRESS_PORT, () => {
    console.log(`Server running on port ${EXPRESS_PORT}`);
    console.log(`Paste this into the ComputerCraft terminal and reboot: \x1b[4mwget http://${HOST}:${EXPRESS_PORT}/ startup.lua\x1b[0m`);
});


# ccModules

## Description

ccModules is a web server built with Express.js designed to serve files and modules from the ``./ccinit/`` and ``./modules/`` directories.
It listens on a port specified in a configuration file. Additionally, it includes a WebSocket server that monitors changes in the ``./modules`` directory and broadcasts updates to connected clients. 
The project also features an authorization system for clients and manages module dependencies. Some core Lua files, required by the modules, are included and cannot function independently without modifications.

## Installation

To install the project, clone the repository and install the dependencies:

```bash
git clone https://github.com/Pivius/ccModules.git
cd ccModules
npm install
```

## Configuration

The project uses a configuration file to set the host, Express port, module path, and WebSocket port. 
You can find the configuration file at ``./config.js``. Here is an example configuration:
```js
module.exports = {
    HOST: 'localhost',
    EXPRESS_PORT: 8113,
    MODULE_PATH: './modules',
    WS_PORT: 8114
};
```

The Lua file ``./ccinit/startup.lua`` also requires configuration. You need to set the ``HOST``, ``HTTP_PORT``, ``WS_PORT``.

## Server Usage
To start the server, run the following command:

```bash
node server.js
```

When a client connects to the WebSocket server, it must send an authorization message with a computer ID. If the computer ID is recognized, the client is authorized immediately. Otherwise, the server will ask for authorization.

The WebSocket server monitors the ``./modules`` directory for changes. When a file is added, changed, or deleted, the server broadcasts a message to all connected clients detailing the change.

The server also manages module dependencies. It can return a module with its dependencies as defined in the module's ``config.json``, and it can add a file to an array while handling any dependencies of the file.

## Client Usage

Configure the ``startup.lua`` file by setting the ``HOST``, ``HTTP_PORT``, and ``WS_PORT`` to match your server's configuration.

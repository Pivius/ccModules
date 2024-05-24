const fs = require('fs');
const path = require('path');
const readline = require('readline');
const WebSocket = require('ws');
const { WS_PORT } = require('./config');
const chokidar = require('chokidar');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const webServer = new WebSocket.Server({ port: WS_PORT });

webServer.on('connection', connectionHandler);

let fileWatcher = null;
let connectedClients = 0;
const authorizedComputers = new Map();

function connectionHandler(ws) {
    console.log('Client connected');
    const authorizationTimeout = setTimeout(() => {
        console.log('Authorization timeout. Disconnecting client.');
        ws.send(JSON.stringify({ type: 'auth', status: 'timeout' }));
        ws.close();
    }, 30 * 1000);

    ws.on('message', (message) => {
        message = JSON.parse(message);

        if (message.type === 'auth') {
            if (authorizedComputers.has(message.computerId)) {
                authorize(ws, message.computerId, authorizationTimeout);
            } else {
                authorizeConnection(ws, message.computerId, authorizationTimeout, rl, authorizedComputers);
            }
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected');
        connectedClients--;
        clearTimeout(authorizationTimeout);

        if (connectedClients === 0) {
            stopWatchingFiles();
        }
    });

    ws.onerror = (error) => {
        console.log(`WebSocket error: ${error}`);
        connectedClients--;
        clearTimeout(authorizationTimeout);

        if (connectedClients === 0) {
            stopWatchingFiles();
        }
    };
}

function broadcastToClients(filePath, action) {
    const relativePath = path.relative(__dirname, filePath);
    const moduleName = relativePath.split(path.sep)[1];
    let content = null;

    if (['add', 'change'].includes(action)) {
        content = fs.readFileSync(filePath, 'utf8');
    }

    webServer.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({ type: 'sync', action, path: relativePath, module: moduleName, content }));
        }
    });
}

function startWatchingFiles() {
    fileWatcher = chokidar.watch('./modules', {
        ignored: /(^|[\/\\])\..*|config\.json$/, // ignore dotfiles and config.json
        persistent: true
    });

    fileWatcher
        .on('add', path => broadcastToClients(path, 'add'))
        .on('change', path => broadcastToClients(path, 'change'))
        .on('unlink', path => broadcastToClients(path, 'unlink'))
        .on('addDir', path => broadcastToClients(path, 'addDir'))
        .on('unlinkDir', path => broadcastToClients(path, 'unlinkDir'));

    console.log('Started watching for file changes');
}

function stopWatchingFiles() {
    if (fileWatcher) {
        fileWatcher.close();
        fileWatcher = null;
        console.log('Stopped watching for file changes');
    }
}

function authorize(ws, computerId, authorizationTimeout) {
    ws.send(JSON.stringify({ type: 'auth', status: 'authorized' }));
    console.log('Connection authorized.');
    clearTimeout(authorizationTimeout);
    startWatchingFiles();
}

function authorizeConnection(ws, computerId, authorizationTimeout, rl, authorizedComputers) {
    rl.question(`Authorize connection from computer ID ${computerId}? (y/n): `, (answer) => {
        if (answer.toLowerCase() === 'y') {
            authorizedComputers.set(computerId, true);
            authorize(ws, computerId, authorizationTimeout);
        } else {
            console.log('Connection rejected.');
            ws.send(JSON.stringify({ type: 'auth', status: 'rejected' }));
            ws.close();
            clearTimeout(authorizationTimeout);
        }
    });
}

module.exports = { connectionHandler, authorizedComputers };
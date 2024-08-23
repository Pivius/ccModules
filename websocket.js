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

const authorizedComputers = new Map();
let fileWatcher = null;
let connectedClients = 0;

function connectionHandler(ws) {
    console.log('Client connected');

    const authorizationTimeout = setTimeout(() => {
        console.log('Authorization timeout. Disconnecting client.');
        ws.send(JSON.stringify({ type: 'auth', status: 'timeout' }));
        ws.close();
    }, 30 * 1000);

    ws.on('message', (message) => handleMessage(ws, message, authorizationTimeout));
    ws.on('close', () => handleClientDisconnect(authorizationTimeout));
    ws.onerror = (error) => handleClientDisconnect(authorizationTimeout, error);
}

function handleMessage(ws, message, authorizationTimeout) {
    const parsedMessage = JSON.parse(message);

    if (parsedMessage.type === 'auth') {
        if (authorizedComputers.has(message.computerId)) {
            authorize(ws, parsedMessage.computerId, authorizationTimeout);
        } else {
            authorizeConnection(ws, parsedMessage.computerId, authorizationTimeout, rl, authorizedComputers);
        }
    } else if (parsedMessage.type === 'file_change') {
        handleFileChangeFromClient(parsedMessage);
    }
}

function handleClientDisconnect(authorizationTimeout, error = null) {
    console.log(error ? `Client disconnected due to error: ${error}` : 'Client disconnected');
    connectedClients--;
    clearTimeout(authorizationTimeout);

    if (connectedClients === 0) stopWatchingFiles();
}

function handleFileChangeFromClient(message) {
    const { path: filePath, module: moduleName, content, action } = message;

    const fullPath = path.join(__dirname, filePath);

    if (['add', 'change'].includes(action)) {
        fs.writeFileSync(fullPath, content, 'utf8');
    } else if (action === 'unlink') {
        fs.unlinkSync(fullPath);
    } else if (action === 'addDir') {
        fs.mkdirSync(fullPath);
    } else if (action === 'unlinkDir') {
        fs.rmdirSync(fullPath);
    }

    broadcastToClients(fullPath, action);
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
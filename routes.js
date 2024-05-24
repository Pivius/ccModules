const express = require('express');
const { getModules, addFileToArray, getModuleWithDependencies } = require('./file');
const fs = require('fs');
const path = require('path');

const router = express.Router();

router.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '/ccinit/startup.lua'));
});

router.get('/modules', (req, res) => {
    res.json(getModules());
});

router.get('/download', (req, res) => {
    let files = [];
    let paths = req.query.paths;
    let prefix = './';

    if (typeof paths === 'string') {
        paths = [paths];
    }

    paths.forEach((filePath) => {
        if (filePath.includes(prefix)) {
            filePath = filePath.replace(prefix, '');
        }

        if (fs.existsSync(prefix + filePath)) {
            files = addFileToArray(files, prefix + '/' + filePath);
        } else if (fs.existsSync(prefix + 'ccinit/' + filePath)) {
            files = addFileToArray(files, prefix + 'ccinit/' + filePath);
        } else if (fs.existsSync(prefix + 'modules/' + filePath)) {
            files = addFileToArray(files, prefix + 'modules/' + filePath);
        } else {
            files[filePath] = null;
        }
    });

    let obj = {};

    files.forEach((file) => {
        let path = file;
        if (path.includes('ccinit/')) {
            path = path.replace('ccinit/', '');
        }
        obj[path] = fs.readFileSync(file, 'utf8');
    });

    res.json(obj);
});

router.get('/init', (req, res) => {
    let files = [];

    files = addFileToArray(files, path.join(__dirname, '/ccinit/manager.lua'));
    files = addFileToArray(files, path.join(__dirname, '/ccinit/sync.lua'));
    files = addFileToArray(files, path.join(__dirname, '/ccinit/config_manager.lua'));
    files = addFileToArray(files, path.join(__dirname, '/ccinit/startup.lua'));

    res.json(files);
});

module.exports = router;
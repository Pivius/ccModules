const fs = require('fs');
const { MODULE_PATH } = require('./config');

function getModuleConfig(moduleName) {
    let config = "{}";

    if (fs.existsSync(`${MODULE_PATH}/${moduleName}/config.json`)) {
        config = fs.readFileSync(`${MODULE_PATH}/${moduleName}/config.json`, 'utf8');
    }

    return JSON.parse(config);
}

function getModules() {
    return fs.readdirSync(MODULE_PATH);
}

function getFileRecursion(path) {
    let arr = [];
    let files = fs.readdirSync(path);

    files.forEach((file) => {
        if (fs.lstatSync(`${path}/${file}`).isDirectory()) {
            arr.push(getFileRecursion(path + "/" + file));
        } else {
            if (file != "config.json") {
                arr.push(file);
            }
        }
    });

    return arr;
}

function getModule(moduleName) {
    return {
        name: moduleName,
        config: getModuleConfig(moduleName),
        files: getFileRecursion(`${MODULE_PATH}/${moduleName}`)
    };
}

function getModuleWithDependencies(moduleName) {
    let modules = [getModule(moduleName)];
    let dependencies = modules[0].config.dependencies || [];

    dependencies.forEach((dependency) => {
        if (!modules.some(module => module.name === dependency)) {
            modules.push(getModule(dependency));
        }
    });

    return modules;
}

function addFileToArray(arr, path, deps = []) {
    if (fs.lstatSync(path).isFile() && !path.includes('config.json')) {
        try {
            const content = fs.readFileSync(path, 'utf8');

            if (content) {
                arr.push(path);
            }
        } catch (error) {
            console.log(`Error reading file: ${path}`);
        }
    } else if (fs.lstatSync(path).isDirectory()) {
        const files = fs.readdirSync(path);

        if (files.includes('config.json')) {
            const config = JSON.parse(fs.readFileSync(path + '/config.json', 'utf8'));

            if (config.dependencies && !deps.includes(path)) {
                deps.push(path.split('/').pop());
                config.dependencies.forEach((dependency) => {
                    if (!deps.includes(dependency)) {
                        deps.push(dependency);
                        arr = addFileToArray(arr, MODULE_PATH + '/' + dependency, deps);
                    }
                });
            }
        }

        files.forEach((file) => {
            if (file !== 'config.json') {
                arr = addFileToArray(arr, path + '/' + file, deps);
            }
        });
    }

    return arr;
}

module.exports = {
    getModules,
    getModuleWithDependencies,
    addFileToArray,
};
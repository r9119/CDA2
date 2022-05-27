'use strict';

const fs = require('fs');
const path = require('path');
const basename = path.basename(__filename);
const dbConfig = require("../config/config.js");
const mongoose = require("mongoose");

mongoose.Promise = global.Promise;

// Connect to DB 
const db = {};
db.mongoose = mongoose;
db.url = dbConfig.url;

// Programatically load models
fs
    .readdirSync(__dirname)
    .filter(file => {
        return (file.indexOf('.') !== 0)
        && (file !== basename)
        && (file.slice(-3) === '.js');
    })
    .forEach(file => {
        db[file.slice(0,-3)] = require(path.join(__dirname, file))(mongoose)
    })


module.exports = db;

// Structure of model loading/model schemas may change if I figure out how to programatically connec to DBs/save one schema to multiple collections
// Multiple collections one schema would be if we saved each countrys data set as its own collections example: spain-emissions, poland-emissions...
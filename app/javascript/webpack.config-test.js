const config = require('./webpack.config.js');

config.target = 'node'
config.mode   = 'development';

module.exports = config;

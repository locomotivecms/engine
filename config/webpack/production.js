const config = require('./development.js');

config.target = 'node'
config.mode   = 'production';
config.optimization = { minimize: true };

module.exports = config;

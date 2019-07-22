const config = require('./development.js');

config.target = 'web'
config.mode   = 'production';
config.optimization = { minimize: true };

module.exports = config;

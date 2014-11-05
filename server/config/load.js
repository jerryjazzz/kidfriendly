
require('coffee-script/register')

var configs = require('./defaults.json');

configs.schema = require('./schema')

module.exports = configs;

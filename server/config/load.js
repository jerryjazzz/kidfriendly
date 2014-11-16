
require('coffee-script/register')

var configs = require('./defaults');

configs.schema = require('./schema')

module.exports = configs;

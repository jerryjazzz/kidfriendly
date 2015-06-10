
{depend, provide} = require('mini-di').newCache()

global.Promise = require('bluebird')
global.depend = depend
global.provide = provide


Request = require('request')
Promise = require('bluebird')

class Http
  constructor: ->

  request: (args) ->
    args.json = args.json ? true
    new Promise (resolve, reject) =>
      Request args, (error, message, body) =>
        if error?
          reject(error)
        else
          resolve(body)

provide.class(Http)

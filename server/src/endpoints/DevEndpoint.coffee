
class DevEndpoint
  constructor: (@app) ->
    @endpoint = require('express')()

    @endpoint.get '/config', (req, res) =>
      res.send(app.config)

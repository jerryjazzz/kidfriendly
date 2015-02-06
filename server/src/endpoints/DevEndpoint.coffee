
class DevEndpoint
  constructor: ->
    @app = depend('App')
    @endpoint = require('express')()

    @endpoint.get '/config', (req, res) =>
      res.send(app.config)

  @create: (app) ->
    (new DevEndpoint(app)).endpoint

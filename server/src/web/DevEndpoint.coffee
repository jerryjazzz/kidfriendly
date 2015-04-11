
class DevEndpoint
  constructor: ->
    @app = depend('App')
    @route = require('express')()

    @route.get '/config', (req, res) =>
      res.send(app.config)

provide('DevEndpoint', DevEndpoint)

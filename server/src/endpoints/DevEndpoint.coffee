
class DevEndpoint
  constructor: ->
    @app = depend('App')
    @route = require('express')()
    get = depend('ExpressGet')
    post = depend('ExpressPost')

    @route.get '/config', (req, res) =>
      res.send(app.config)

    get @route, '/tweak/:name', (req) =>
      depend('Tweaks').get(req.params.name)

    get @route, '/tweaks', (req) =>
      depend('Tweaks').getAll()

    post @route, '/tweak/:name', (req) =>
      value = req.body.value
      depend('Tweaks').set(req.params.name, value)

provide('endpoint/api/dev', DevEndpoint)

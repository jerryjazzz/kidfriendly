
class InternalEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('dao/place')
    @route = require('express')()
    get = depend('ExpressGet')

    get @route, '/trigger_nightly', (req) =>
      depend('NightlyTasks').run()

provide.class('endpoint/api/internal', InternalEndpoint)

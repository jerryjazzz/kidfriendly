
class InternalEndpoint
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')
    @route = require('express')()
    get = depend('ExpressGet')

    get @route, '/trigger_nightly', (req) =>
      depend('NightlyTasks').run()

provide.class('endpoint/api/internal', InternalEndpoint)

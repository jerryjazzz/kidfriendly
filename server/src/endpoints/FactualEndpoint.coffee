
class FactualEndpoint
  constructor: (@app) ->
    @route = require('express')()
    @factual = @app.modules.factual

    Get @route, '/geo', {}, (req) =>
      @app.log(req.query)
      @factual.geoSearch(lat: req.query.lat, long: req.query.long, range: req.query.range)

  @create: (app) ->
    (new FactualEndpoint(app)).route

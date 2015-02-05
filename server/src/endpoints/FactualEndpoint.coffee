
class FactualEndpoint
  constructor: (@app) ->
    @route = require('express')()
    @factual = @app.modules.factual

    Get @route, '/geo', {}, (req) =>
      @app.log(req.query)
      {lat, long, meters} = req.query
      @factual.geoSearch({lat, long, meters})

  @create: (app) ->
    (new FactualEndpoint(app)).route

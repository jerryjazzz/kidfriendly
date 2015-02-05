
class SearchEndpoint
  constructor: (@app) ->
    factual = @app.modules.factual
    placeSearch = @app.modules.placeSearch

    @route = require('express')()

    Get @route, '/nearby', {}, (req) =>
      {lat, long, meters} = req.query

      # Just for beta purposes, first do a Factual pull for this range.
      factual.geoSearch({lat, long, meters})
      .then ->
        placeSearch.search({lat, long, meters})

  @create: (app) ->
    (new SearchEndpoint(app)).route

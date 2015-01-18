
class SearchEndpoint
  defaultSearchRange: 16000

  constructor: ->
    @app = depend('App')
    factualService = depend('FactualService')
    placeSearch = depend('PlaceSearch')

    @route = require('express')()

    Get @route, '/nearby', {}, (req) =>
      {lat, long, meters} = req.query

      meters = meters ? @defaultSearchRange

      # Just for beta purposes, first do a Factual pull for this range.
      factual.geoSearch({lat, long, meters})
      .then ->
        placeSearch.search({lat, long, meters})

  @create: (app) ->
    (new SearchEndpoint(app)).route

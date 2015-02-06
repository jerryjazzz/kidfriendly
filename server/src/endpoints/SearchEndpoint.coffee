
class SearchEndpoint
  defaultSearchRange: 16000

  constructor: ->
    @app = depend('App')
    factualService = depend('FactualService')
    placeSearch = depend('PlaceSearch')

    @route = require('express')()

    Get @route, '/nearby', {}, (req) =>
      {lat, long, zipcode, meters} = req.query
      meters = meters ? @defaultSearchRange
      searchOptions = {lat, long, zipcode, meters}

      # Just for beta purposes, first do a Factual pull for this range.
      factualService.geoSearch(searchOptions)
      .then ->
        placeSearch.search(searchOptions)
      .then (places) ->
        console.log('places 2 ', places)
        place.toClient() for place in places

  @create: (app) ->
    (new SearchEndpoint(app)).route

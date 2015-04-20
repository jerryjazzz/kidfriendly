
class SearchEndpoint
  defaultSearchRange: 16000

  constructor: ->
    @app = depend('App')
    factualService = depend('FactualService')
    factualConsumer = depend('FactualConsumer')
    placeSearch = depend('PlaceSearch')
    @route = require('express')()
    get = depend('ExpressGet')

    get @route, '/nearby', (req) =>
      {lat, long, zipcode, meters} = req.query
      meters = meters ? @defaultSearchRange
      searchOptions = {lat, long, zipcode, meters}

      # Just for beta purposes, first do a Factual pull for this range.
      factualConsumer.geoSearch(searchOptions)
      .then ->
        placeSearch.search(searchOptions)
      .then (places) ->
        place.toClient() for place in places

    get @route, '/exceldump', (req) =>
      {lat, long, zipcode, meters} = req.query
      meters = meters ? @defaultSearchRange
      searchOptions = {lat, long, zipcode, meters}

      factualConsumer.geoSearch(searchOptions)
      .then ->
        placeSearch.search(searchOptions)
      .then (places) ->
        {presentation: 'view/placesCSV', places: places}

provide('endpoint/api/search', SearchEndpoint)

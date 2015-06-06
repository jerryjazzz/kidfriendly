
class SearchEndpoint

  constructor: ->
    @app = depend('App')
    factualService = depend('FactualService')
    factualConsumer = depend('FactualConsumer')
    placeSearch = depend('PlaceSearch')
    userAuthentication = depend('UserAuthentication')
    MyPlaceDetails = depend('MyPlaceDetails')
    @route = require('express')()
    get = depend('ExpressGet')

    get @route, '/nearby', (req) =>

      searchParams = placeSearch.fromRequest(req)

      # Just for beta purposes, first do a Factual pull for this range.
      factualConsumer.geoSearch(searchParams)
      .then ->
        placeSearch.search(searchParams)
      .then (places) ->
        (place.toClient() for place in places)
      .then (places) ->
        MyPlaceDetails.maybeAnnotate(req, places)

    get @route, '/exceldump', (req) =>
      searchOptions = placeSearch.fromRequest(req)

      factualConsumer.geoSearch(searchOptions)
      .then ->
        placeSearch.search(searchOptions)
      .then (places) ->
        {view: 'view/placesCSV', places: places}

    get @route, '/resolve', (req) =>
      placeSearch.fromRequest(req)

    get @route, '/to-factual-url', (req) =>
      searchParams = placeSearch.fromRequest(req)
      factualService.getUrl(searchParams)

provide.class('endpoint/api/search', SearchEndpoint)

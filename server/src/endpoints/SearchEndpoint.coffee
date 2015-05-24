
class SearchEndpoint

  constructor: ->
    @app = depend('App')
    factualService = depend('FactualService')
    factualConsumer = depend('FactualConsumer')
    placeSearch = depend('PlaceSearch')
    userAuthentication = depend('UserAuthentication')
    userAnnotatedSearchResults = depend('UserAnnotatedSearchResults')
    @route = require('express')()
    get = depend('ExpressGet')

    get @route, '/nearby', (req) =>

      options = placeSearch.resolveSearchQuery(req.query)

      # Just for beta purposes, first do a Factual pull for this range.
      factualConsumer.geoSearch(options)
      .then ->
        places: placeSearch.search(options)
        user: userAuthentication.userFromRequest(req)
      .props()
      .then ({places, user}) ->
        places = (place.toClient() for place in places)

        if user?
          userAnnotatedSearchResults.annotate(places, user.user_id)
        else
          places

    get @route, '/exceldump', (req) =>
      searchOptions = placeSearch.resolveSearchQuery(req.query)

      factualConsumer.geoSearch(searchOptions)
      .then ->
        placeSearch.search(searchOptions)
      .then (places) ->
        {view: 'view/placesCSV', places: places}

    get @route, '/resolve', (req) =>
      placeSearch.resolveSearchQuery(req.query)

    get @route, '/to-factual-url', (req) =>
      options = placeSearch.resolveSearchQuery(req.query)
      factualService.getUrl(options)

provide.class('endpoint/api/search', SearchEndpoint)

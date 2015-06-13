
provide 'endpoint/api/search', ->
  FactualService = depend('FactualService')
  FactualConsumer = depend('FactualConsumer')
  PlaceSearch = depend('PlaceSearch')
  MyPlaceDetails = depend('MyPlaceDetails')

  '/nearby': (req) ->

    searchParams = PlaceSearch.fromRequest(req)

    # Just for beta purposes, first do a Factual pull for this range.
    FactualConsumer.geoSearch(searchParams)
    .then ->
      PlaceSearch.search(searchParams)
    .then (places) ->
      (place.toClient() for place in places)
    .then (places) ->
      MyPlaceDetails.maybeAnnotate(req, places)

  '/exceldump': (req) ->
    searchOptions = PlaceSearch.fromRequest(req)

    FactualConsumer.geoSearch(searchOptions)
    .then ->
      PlaceSearch.search(searchOptions)
    .then (places) ->
      {view: 'view/placesCSV', places: places}

  '/resolve': (req) ->
    PlaceSearch.fromRequest(req)

  '/to-factual-url': (req) ->
    searchParams = PlaceSearch.fromRequest(req)
    FactualService.getUrl(searchParams)

'use strict'

Geolib = require('geolib')
Cities = require('cities')

DefaultDistanceMiles = 2

class SearchParams

  constructor: ({@zipcode, @lat, @long, @meters, @miles}) ->
    if @meters? and @miles?
      throw new Error("can't specify both 'meters' and 'miles")

    if @zipcode? and @lat?
      throw new Error("can't specify both 'zipcode' and 'lat")

    if @lat? and not @long?
      throw new Error("must specify 'long' with 'lat'")

    if @long? and not @lat?
      throw new Error("must specify 'lat' with 'long'")

    if @miles? and not @meters?
      @meters = MilesToMeters(@miles)

    if not @meters?
      @meters = MilesToMeters(DefaultDistanceMiles)

  toGeoLocation: ->
    if @zipcode?
      cityLookup = Cities.zip_lookup(@zipcode)
      if not cityLookup?
        throw new Error("zipcode not found: " + @zipcode)
      return {lat: cityLookup.latitude, long: cityLookup.longitude}

    return {lat: @lat, long: @long}

  @fromRequest: (req) ->
    new SearchParams(req.query)

class PlaceSearch
  SearchLimit: 120
  SearchDistanceMiles: 2
  FinalResultLimit: 100

  constructor: ->
    @placeDao = depend('dao/place')
    @geom = depend('GeomUtil')
    @tweaks = depend('Tweaks')

  fromRequest: (req) ->
    SearchParams.fromRequest(req)

  ###
  resolveSearchQuery: (query) ->
    options = {lat, long, zipcode, meters, miles} = query

    if options.zipcode?
      cityLookup = Cities.zip_lookup(options.zipcode)
      if not cityLookup?
        throw new Error("zipcode not found: " + options.zipcode)
      [options.lat, options.long] = [cityLookup.latitude, cityLookup.longitude]

    return options
  ###

  search: (searchParams) ->
    if searchParams.zipcode?
      @placeDao.find (query) =>
        query.where(zipcode: searchParams.zipcode)
        @sortAndLimitQuery(query)

    else
      @geoSearch(searchParams)

  geoSearch: (searchParams) ->
    bounds = @geom.getBounds(searchParams)
    
    @placeDao.find (query) =>
      # Filter to nearest rectangle
      query.andWhere('lat', '>', bounds.lat1)
      query.andWhere('lat', '<', bounds.lat2)
      query.andWhere('long', '>', bounds.long1)
      query.andWhere('long', '<', bounds.long2)

      @sortAndLimitQuery(query)

    .then (places) =>
      #console.log("sql gave #{places.length} places")
      @checkDistance(places, searchParams)
    .then (places) =>
      places.filter((place) -> not place.details?.factual_raw?.chain_id)
    .then (places) =>
      places.slice(0, @FinalResultLimit)

  checkDistance: (places, searchParams) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      #console.log("distance from: ", {latitude: place.lat, longitude: place.long})
      #console.log("distance to: ", {latitude: searchParams.lat, longitude: searchParams.long})
      place.context.distance = Geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: searchParams.lat, longitude: searchParams.long})
      #console.log("is ", place.context.distance)

    return places.filter (place) -> place.context.distance < searchParams.meters

  sortAndLimitQuery: (query) ->
    query.orderByRaw('upvote_count - downvote_count desc')
    query.limit(@SearchLimit)

  ###
  sortPlaces: (places) ->
    #penaltyPerMile = @tweaks.get('sort.penalty_points_per_10mi') / 10

    for place in places
      distance = place.context.distance
      #place.context.adjustedRating = place.rating \
      # - MetersToMiles(distance) * penaltyPerMile

      # ignore rating
      place.context.adjustedRating = -distance

    places.sort((a,b) -> b.context.adjustedRating - a.context.adjustedRating)
    return places
  ###

provide.class(PlaceSearch)

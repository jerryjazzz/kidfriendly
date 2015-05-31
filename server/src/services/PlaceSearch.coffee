'use strict'

Geolib = require('geolib')
Cities = require('cities')

class PlaceSearch
  SearchLimit: 120
  SearchDistanceMiles: 2
  FinalResultLimit: 100

  constructor: ->
    @placeDao = depend('dao/place')
    @geom = depend('GeomUtil')
    @tweaks = depend('Tweaks')

  resolveSearchQuery: (query) ->
    options = {lat, long, zipcode, meters, miles} = query

    if options.miles? and not options.meters?
      options.meters = MilesToMeters(options.miles)

    if not options.meters?
      options.meters = MilesToMeters(@SearchDistanceMiles)

    if options.zipcode?
      cityLookup = Cities.zip_lookup(options.zipcode)
      if not cityLookup?
        throw new Error("zipcode not found: " + options.zipcode)
      [options.lat, options.long] = [cityLookup.latitude, cityLookup.longitude]

    return options

  search: (searchOptions) ->
    bounds = @geom.getBounds(searchOptions)
    
    @placeDao.find (query) =>
      # Filter to nearest rectangle
      query.andWhere('lat', '>', bounds.lat1)
      query.andWhere('lat', '<', bounds.lat2)
      query.andWhere('long', '>', bounds.long1)
      query.andWhere('long', '<', bounds.long2)

      query.orderByRaw('upvote_count - downvote_count desc')

      query.limit(@SearchLimit)

    .then (places) =>
      #console.log("sql gave #{places.length} places")
      @checkDistance(places, searchOptions)
    .then (places) =>
      places.filter((place) -> not place.details?.factual_raw?.chain_id)
    .then (places) =>
      places.slice(0, @FinalResultLimit)

  checkDistance: (places, searchOptions) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      #console.log("distance from: ", {latitude: place.lat, longitude: place.long})
      #console.log("distance to: ", {latitude: searchOptions.lat, longitude: searchOptions.long})
      place.context.distance = Geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: searchOptions.lat, longitude: searchOptions.long})
      #console.log("is ", place.context.distance)

    return places.filter (place) -> place.context.distance < searchOptions.meters

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

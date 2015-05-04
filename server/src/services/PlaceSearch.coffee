'use strict'

Geolib = require('geolib')
Cities = require('cities')

class PlaceSearch
  SearchLimit: 100
  DefaultSearchRange: 16000

  constructor: ->
    @placeDao = depend('PlaceDAO')
    @geom = depend('GeomUtil')

  resolveSearchQuery: (query) ->
    options = {lat, long, zipcode, meters, miles} = query

    if options.miles? and not options.meters?
      options.meters = options.miles * 1609.34

    options.meters = options.meters ? @DefaultSearchRange

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

      query.orderBy('rating', 'desc')

      query.limit(@SearchLimit)

    .then (places) =>
      #console.log("sql gave #{places.length} places")
      @checkDistance(places, searchOptions)
    .then (places) =>
      #console.log("after checkdistance, have #{places.length} places")
      @computeSortOrder(places)

  checkDistance: (places, searchOptions) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      #console.log("distance from: ", {latitude: place.lat, longitude: place.long})
      #console.log("distance to: ", {latitude: searchOptions.lat, longitude: searchOptions.long})
      place.context.distance = Geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: searchOptions.lat, longitude: searchOptions.long})
      #console.log("is ", place.context.distance)

    return places.filter (place) -> place.context.distance < searchOptions.meters

  computeSortOrder: (places) ->
    for place in places
      place.context.adjustedRating = place.rating + @pointsForDistance(place.distance)

    places.sort((a,b) -> b.context.adjustedRating - a.context.adjustedRating)
    return places

  pointsForDistance: (meters) ->
    # Calculate the penalty points for a place which is 'meters' away.
    # This uses a curve, so the difference between 0 and 10 km is more
    # significant than the difference between 10km and 20km.

    referencePoints = [
      [0,0]
      [5000,0]     # up to 5km, no penalty
      [10000,-10]  # 10km, minus 10 rating points
      [15000,-13]  # 15km, minus 13 points
      [20000,-15]  # 20km, minus 15 points
    ]

    findYUsingReference = (n, points) ->
      if n <= points[0][0]
        return points[0][1]

      for i,ref of points
        i = parseInt(i)
        if (i+1) >= points.length
          return ref[1]

        nextRef = points[i+1]
        if (n >= ref[0]) and (n <= nextRef[0])

          scale = (n - ref[0]) / (nextRef[0] - ref[0])
          res = ref[1] + (nextRef[1] - ref[1]) * scale
          return res

      return points[points.length-1][1]

    return findYUsingReference(meters, referencePoints)


provide('PlaceSearch', PlaceSearch)

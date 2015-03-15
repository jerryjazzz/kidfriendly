'use strict'

geolib = require('geolib')
Cities = require('cities')

class PlaceSearch
  SearchLimit: 100

  constructor: ->
    @placeDao = depend('PlaceDAO')

  resolveZipcode: (searchOptions) ->
    if searchOptions.zipcode?
      cityLookup = Cities.zip_lookup(searchOptions.zipcode)
      if not cityLookup?
        throw new Error("zipcode not found: " + searchOptions.zipcode)
      [searchOptions.lat, searchOptions.long] = [cityLookup.latitude, cityLookup.longitude]

    return searchOptions

  search: (searchOptions) ->
    @resolveZipcode(searchOptions)

    bounds = GeomUtil.getBounds(searchOptions)

    @placeDao.get (query) ->
      # Filter to nearest rectangle
      query.orWhere('lat', '>', bounds.lat1)
      query.orWhere('lat', '<', bounds.lat2)
      query.orWhere('long', '>', bounds.long1)
      query.orWhere('long', '<', bounds.long2)

      query.orderBy('rating', 'desc')

      query.limit(@SearchLimit)

    .then (places) =>
      @checkDistance(places, searchOptions)
    .then (places) =>
      @computeSortOrder(places)

  checkDistance: (places, searchOptions) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      place.context.distance = geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: searchOptions.lat, longitude: searchOptions.long})

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

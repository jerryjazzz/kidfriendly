'use strict'

geolib = require('geolib')
Cities = require('cities')

class PlaceSearch
  constructor: ->
    @app = depend('App')
    @placeDao = depend('PlaceDAO')

  resolveZipcode: (searchOptions) ->
    if searchOptions.zipcode?
      cityLookup = Cities.zip_lookup(searchOptions.zipcode)
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

    .then (places) =>
      places = @checkDistance(places, searchOptions)
      return places

  checkDistance: (places, searchOptions) ->
    # Store 'distance' on each result, and filter out places that are too far.

    for place in places
      place.context.distance = geolib.getDistance({latitude: place.lat, longitude: place.long},
          {latitude: searchOptions.lat, longitude: searchOptions.long})

    return places.filter (place) -> place.context.distance < searchOptions.meters

provide('PlaceSearch', PlaceSearch)

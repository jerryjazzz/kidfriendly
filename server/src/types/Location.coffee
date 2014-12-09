
class Location
  constructor: (@lat, @long) ->

  @fromGoogleLocation: (location) ->
    new Location(location.lat, location.lng)

  addLat: (lat) ->
    new Location(@lat + lat, @long)
  addLong: (long) ->
    new Location(@lat, @long + long)

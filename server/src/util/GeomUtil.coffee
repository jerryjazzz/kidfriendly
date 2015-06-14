
Geolib = require('geolib')

toRadians = (degrees) ->
  degrees / 180.0 * Math.PI
toDegrees = (radians) ->
  radians / Math.PI * 180

EarthRadiusMeters = 6371000

GeomUtil =

  milesToMeters: (miles) ->
    return 1609.34 * miles
  
  sort2: (x, y) ->
    if x < y
      [x, y]
    else
      [y, x]

  getBounds: ({lat, long, meters}) ->
    bounds = Geolib.getBoundsOfDistance({latitude:lat, longitude:long}, meters)

    out = {lat1:0,lat2:0,long1:0,long2:0}
    [out.lat1, out.lat2] = @sort2(bounds[0].latitude, bounds[1].latitude)
    [out.long1, out.long2] = @sort2(bounds[0].longitude, bounds[1].longitude)
    return out

  getDistance: (loc1, loc2) ->
    Geolib.getDistance({latitude: loc1.lat, longitude: loc1.long},
      {latitude: loc2.lat, longitude: loc2.long})

  closerThan: (loc, meters) ->
    (compareLoc) =>
      return @getDistance(loc, compareLoc) < meters

  latLongDeltaFromDistance: (latLong, distanceMeters) ->
    # Returns a delta (x,y) where, if you start at latLong and travel distanceMeters,
    # the location will be within +/- the delta.
    dlat = distanceMeters / EarthRadiusMeters
    dlong = Math.asin(Math.sin(dlat) / Math.cos(toRadians(latLong.lat)))
    return {dlat: toDegrees(dlat), dlong: toDegrees(dlong)}

exports.GeomUtil = GeomUtil
provide('GeomUtil', -> GeomUtil)

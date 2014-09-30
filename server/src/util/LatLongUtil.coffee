
toRadians = (degrees) ->
  degrees / 180.0 * Math.PI
toDegrees = (radians) ->
  radians / Math.PI * 180

LatLongUtil =
  earthRadiusMiles: 3959
  areas:
    phoenix: new Square(new Location(33.90, -112.53), new Location(33.19, -111.50))

  latLongDeltaFromDistance: (latLong, distanceMiles) ->
    # Returns a delta (x,y) where, if you start at latLong and travel distanceMiles,
    # the location will be within +/- the delta.
    dlat = distanceMiles / LatLongUtil.earthRadiusMiles
    dlong = Math.asin(Math.sin(dlat) / Math.cos(toRadians(latLong.lat)))
    return {dlat: toDegrees(dlat), dlon: toDegrees(dlong)}

exports.LatLongUtil = LatLongUtil

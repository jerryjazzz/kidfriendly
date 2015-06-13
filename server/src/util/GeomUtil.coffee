
Geolib = require('geolib')

GeomUtil =
  milesToMeters: (miles) ->
    return 1609.34 * miles
  
  sort2: (x, y) ->
    if x < y
      [x, y]
    else
      [y, x]

  # Bucket sizes were chosen so that one sector is about 40x40 km
  # Warning! If these bucket sizes are changed, then all existing sector_ids become invalid.
  sectorBucketSizeLat: 0.359326
  sectorBucketSizeLong: 0.428448

  sectorCoordsForLocation: (lat, long) ->
    {x: Math.floor(lat / @sectorBucketSizeLat), y: Math.floor(long / @sectorBucketSizeLong)}

  sectorIdForCoords: (coords) ->
    "1-#{coords.x}-#{coords.y}"

  sectorIdForLocation: (lat, long) ->
    coords = @sectorCoordsForLocation(lat, long)
    @sectorIdForCoords(coords)

  getBounds: ({lat, long, meters}) ->
    bounds = Geolib.getBoundsOfDistance({latitude:lat, longitude:long}, meters)

    out = {lat1:0,lat2:0,long1:0,long2:0}
    [out.lat1, out.lat2] = @sort2(bounds[0].latitude, bounds[1].latitude)
    [out.long1, out.long2] = @sort2(bounds[0].longitude, bounds[1].longitude)
    return out

  sectorIdsForLocationDistance: ({lat, long, meters}) ->
    bounds = Geolib.getBoundsOfDistance({latitude:lat, longitude:long}, meters)
    coords = [@sectorCoordsForLocation(bounds[0]), @sectorCoordsForLocation(bounds[1])]

    [x1, x2] = @sort2(coords[0].x, coords[1].x)
    [y1, y2] = @sort2(coords[0].y, coords[1].y)

    results = []
    for x in [x1..x2]
      for y in [y1..y2]
        results.push(@sectorIdForCoords({x,y}))
    results

  getDistance: (loc1, loc2) ->
    Geolib.getDistance({latitude: loc1.lat, longitude: loc1.long},
      {latitude: loc2.lat, longitude: loc2.long})

  closerThan: (loc, meters) ->
    (compareLoc) =>
      return @getDistance(loc, compareLoc) < meters

exports.GeomUtil = GeomUtil
provide('GeomUtil', -> GeomUtil)

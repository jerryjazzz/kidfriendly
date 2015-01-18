
geolib = require('geolib')

GeomUtil =
  milesToMeters: (miles) ->
    return 1609.34 * miles

  # Bucket sizes were chosen so that one sector is about 40x40 km
  # Warning! If bucket sizes are changed, then all existing sector_ids become invalid.
  sectorBucketSizeLat: 0.359326
  sectorBucketSizeLong: 0.428448

  sectorCoordsForLocation: (lat, long) ->
    {x: Math.floor(lat % @sectorBucketSizeLat), y: Math.floor(long % @sectorBucketSizeLong)}

  sectorIdForCoords: (coords) ->
    "1-#{coords.x}-#{coords.y}"

  sectorIdForLocation: (lat, long) ->
    coords = @sectorCoordsForLocation(lat, long)
    @sectorIdForCoords(coords)

  sectorIdsForLocationDistance: (latitude, longitude, meters) ->
    bounds = geolib.getBoundsOfDistance({latitude, longitude}, meters)
    coords = [@sectorCoordsForLocation(bounds[0]), @sectorCoordsForLocation(bounds[1])]

    sort = (x, y) ->
      if x < y
        [x, y]
      else
        [y, x]

    [x1, x2] = sort(coords[0].x, coords[1].x)
    [y1, y2] = sort(coords[0].y, coords[1].y)

    results = []
    for x in [x1..x2]
      for y in [y1..y2]
        results.push(@sectorIdForCoords({x,y})
    results

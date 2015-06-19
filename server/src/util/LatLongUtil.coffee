
toRadians = (degrees) ->
  degrees / 180.0 * Math.PI
toDegrees = (radians) ->
  radians / Math.PI * 180

class Vec2
  constructor: (@x, @y) ->
  addX: (x) ->
    new Vec2(@x + x, @y)
  addY: (y) ->
    new Vec2(@x, @y + y)


class Square
  isSquare: true
  constructor: (@topLeft, @bottomRight) ->

sort2 = (x, y) ->
  if x > y
    [y, x]
  else
    [x, y]

LatLongUtil =
  earthRadiusMiles: 3959

  parse: (latLongString) ->
    items = latLongString.split(',')
    return new Location(parseFloat(items[0]), parseFloat(items[1]))


  latticePointsForAreaSimpler: (area, radiusMiles) ->
    if not area.isSquare
      throw new Error("only works on squares")

    output = []
    offsetLong = false
    latLongDelta = LatLongUtil.latLongDeltaFromDistance(area.topLeft, radiusMiles*2)

    rowStart = area.topLeft
    [latStart, latEnd] = sort2(area.topLeft.lat, area.bottomRight.lat)
    [longStart, longEnd] = sort2(area.topLeft.long, area.bottomRight.long)

    for currentLat in [latStart..latEnd] by latLongDelta.dlat
      for currentLong in [longStart..longEnd] by latLongDelta.dlong
        if offsetLong
          currentLong += latLongDelta.dlong / 2
        output.push(new Location(currentLat, currentLong))
      offsetLong = not offsetLong
    return output

exports.LatLongUtil = LatLongUtil

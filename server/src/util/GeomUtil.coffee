
class Vec2
  constructor: (@x, @y) ->
  addX: (x) ->
    new Vec2(@x + x, @y)
  addY: (y) ->
    new Vec2(@x, @y + y)

class Location
  constructor: (@lat, @long) ->
  addLat: (lat) ->
    new Location(@lat + lat, @long)
  addLong: (long) ->
    new Location(@lat, @long + long)

class Square
  isSquare: true
  constructor: (@topLeft, @bottomRight) ->

GeomUtil =
  ###
  latticePointsForArea: (area, circleRadius) ->
    # Returns a list of points with the goal of completely covering the 'area' with circles.
    # Each point in the list is the center of a circle with the given radius.

    if not area.isSquare
      throw new Error("only works on squares")

    output = []

    # math
    distanceBetweenPoints = {}
    distanceBetweenPoints.x = circleRadius * Math.sin(120/180.0*Math.PI) / Math.sin(30/180.0*Math.PI)
    distanceBetweenPoints.y = distanceBetweenPoints.x * Math.sin(60/180.0*Math.PI)

    rowStart = area.topLeft
    offsetX = false

    while rowStart.y < area.bottomRight.y
      current = rowStart

      if offsetX
        current = current.addX(distanceBetweenPoints.x / 2)

      while current.x < area.bottomRight.x
        output.push(current)

        current = current.addX(distanceBetweenPoints.x)

      rowStart = rowStart.addY(distanceBetweenPoints.y)
      offsetX = not offsetX

    return output
  ###

  latticePointsForAreaSimpler: (area, latLongDelta) ->
    if not area.isSquare
      throw new Error("only works on squares")

    output = []
    rowStart = area.topLeft
    offsetLong = false

    while rowStart.lat < area.bottomRight.lat
      current = rowStart

      if offsetLong
        current = current.addLong(latLongDelta.long / 2)

      while current.long < area.bottomRight.long
        output.push(current)

        current = current.addLong(latLongDelta.long)

      rowStart = rowStart.addLat(latLongDelta.lat)
      offsetLong = not offsetLong

    return output





class Place
  constructor: ({@place_id, @name, @lat, @long, @rating, @factual_id, @details}) ->

    if not @details?
      @details = {}
    else if typeof @details == 'string'
      @details = JSON.parse(@details)

    @original = null
    @dataSource = null

    # 'context' contains mutable data specific to the use case, such as the 'distance' on a
    # location search.
    @context = {}

  @fromDatabase: (fields) ->
    place = new Place(fields)
    place.dataSource = 'db'
    Object.freeze(place)
    Object.freeze(place.details)
    return place

  @make: (fields) ->
    place = new Place(fields)
    place.dataSource = 'local'
    return place

  startPatch: ->
    if this.dataSource != 'db'
      throw Error("Place.startPatch can only be called on original DB data")
    place = new Place(this)
    place.original = this
    place.dataSource = 'local'
    return place

  toClient: ->
    # Return this place in a format for client usage.
    fields = {}
    for k in ['place_id', 'name', 'lat', 'long', 'rating', 'factual_id']
      fields[k] = this[k]
    for k,v of @context
      fields[k] = v
    for k,v of @details
      fields[k] = v
    return fields

  getFactualUrl: ->
    "http://factual.com/#{@factual_id}"

exports.Place = Place

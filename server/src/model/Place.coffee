

class Place
  constructor: ({@place_id, @name, @lat, @long, @rating, @factual_id, @details, @dataSource}) ->

    if not @details?
      @details = {}
    else if typeof @details == 'string'
      @details = JSON.parse(@details)

    if not @dataSource?
      @dataSource = 'local'

    # 'context' contains mutable data specific to the use case, such as the 'distance' on a
    # location search.
    @context = {}

    Object.freeze(this)

  toClient: ->
    fields = {}
    for k in ['place_id', 'name', 'lat', 'long', 'rating', 'factual_id']
      fields[k] = this[k]
    for k,v of @context
      fields[k] = v
    for k,v of @details
      fields[k] = v
    return fields

  withPatch: (patch) ->
    fields = {}
    for own k,v of this
      fields[k] = v
    for k,v of patch
      switch k
        when 'details'
          fields[k] = ObjectUtil.merge(@details, v)
        else
          fields[k] = v

    fields.dataSource = 'local'
    return Place.make(fields)

  @make: (fields) ->
    return new Place(fields)

exports.Place = Place

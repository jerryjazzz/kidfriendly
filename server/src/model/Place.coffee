

class Place
  constructor: ({@place_id, @name, @lat, @long, @rating, @factual_id, @details, @dataSource}) ->

    if not @details?
      @details = {}
    else if typeof @details == 'string'
      @details = JSON.parse(@details)

    if not @dataSource?
      @dataSource = 'local'

    Object.freeze(this)

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

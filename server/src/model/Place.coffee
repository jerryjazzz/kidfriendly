
class Place
  constructor: (initialValues) ->
    for k,v of initialValues
      this[k] = v

    @reviews = []
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
      if k in ['address','hours','tel','website','detailedRatings','price','locality','region','postcode']
        fields[k] = v

      # TODO: don't send factual_raw
      if k == 'factual_raw'
        fields[k] = v

    fields['reviews']=[]
    for review in @reviews
      fields['reviews'].push review.toClient()
    return fields

  getFactualUrl: ->
    "http://factual.com/#{@factual_id}"

provide('Place', -> Place)
provide('newPlace', -> (fields) -> new Place(fields))

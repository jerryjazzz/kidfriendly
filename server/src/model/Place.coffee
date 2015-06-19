
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

  @table:
    name: 'place'
    primary_key: 'place_id'

  @fields:
    place_id:
      type: 'id'
    name:
      type: 'varchar(255)'
    lat:
      type: 'real'
    long:
      type: 'real'
    zipcode:
      type: 'varchar(10)'
    rating:
      type: 'integer'
    factual_id:
      type: 'varchar(61)'
      unique: true
      private: true
    factual_consume_ver:
      type: 'integer'
      private: true
    details:
      type: 'json'
    upvote_count:
      type: 'integer'
      default: 0
    downvote_count:
      type: 'integer'
      default: 0
    thumb_img_url:
      type: 'text'
    big_img_url:
      type: 'text'
    created_at:
      type: 'timestamp'
    updated_at:
      type: 'timestamp'
    source_ver:
      type: 'integer'

  @fromDatabase: (fields) ->
    place = new Place(fields)
    place.dataSource = 'db'
    return place

  @make: (fields) ->
    place = new Place(fields)
    place.dataSource = 'local'
    return place

  toClient: ->
    # Return this place in a format for client usage.
    fields = {}
    for k,fieldDetails of Place.fields when not (fieldDetails.private ? false)
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
    fields.type = 'Place'

    fields.upvote_count ?= 0
    fields.downvote_count ?= 0

    return fields

  getFactualUrl: ->
    "http://factual.com/#{@factual_id}"

provide('Place', -> Place)
provide('newPlace', -> (fields) -> new Place(fields))

class Review
  constructor: ({@review_id, @user_id, @place_id, @reviewer_name, @body, @created_at, @updated_at}) ->

    if not @body?
      @body = {}
    else if typeof @body == 'string'
      @body = JSON.parse(@body)

    @original = null
    @dataSource = null

    # 'context' contains mutable data specific to the use case, such as the 'distance' on a
    # location search.
    @context = {}

  @table:
    name: 'review'

  @fields:
    review_id: {}
    place_id: {}
    user_id: {}
    body: {}
    reviewer_name: {}
    created_at: {}
    updated_at: {}

  toDatabase: ->
    fields = {}
    for k in ['review_id', 'place_id', 'user_id', 'body', 'reviewer_name']
      fields[k] = this[k]
    fields

  @fromDatabase: (fields) ->
    review = new Review(fields)
    review.dataSource = 'db'
    return review

  @make: (fields = {}) ->
    review = new Review(fields)
    review.dataSource = 'local'
    return review

  toClient: ->
    # Return this place in a format for client usage.
    fields = {}
    for k in ['review_id', 'user_id', 'place_id', 'reviewer_name', 'body', 'updated_at', 'created_at']
      fields[k] = this[k]
    for k,v of @context
      fields[k] = v
    for k,v of @details
      fields[k] = v
    return fields

  getFactualUrl: ->
    "http://factual.com/#{@factual_id}"

provide('Review', -> Review)


class PlaceDAO
  constructor: ->
    @app = depend('App')
    @UpdateableFields = ['name','lat','long','rating','factual_id','details','factual_consume_ver']
    @InsertableFields = @UpdateableFields.concat(['place_id'])
    @ReadableFields = @InsertableFields
    @modelClass = depend('Place')

  get: (queryFunc) ->
    # queryFunc is a func that takes a Knex query object, and hopefully adds a 'where'
    # clause or something.
    query = @app.db.select.apply(@ReadableFields).from('place')
    queryFunc(query)
    query.then (rows) =>
      places = for row in rows
        @modelClass.fromDatabase(row)
      places

  getId: (id) ->
    @get((query) -> query.where(place_id:id))
    .then (places) -> places[0]

  getWithReviews:(placeId) ->
    query = @app.db.select('place.place_id','name','lat','long','rating','factual_id','details',
    'reviewer_name', 'body', 'review_id', 'review.created_at', 'review.updated_at').from('place')
    .leftOuterJoin('review', 'place.place_id', 'review.place_id').where('place.place_id', placeId)
    query.toSQL()
    query.then (rows) ->
      if rows? and rows.length > 0
        place = @modelClass.fromDatabase(rows[0])
        for row in rows
          if row.review_id?
            place.reviews.push Review.fromDatabase(row)
        place

  insert: (place) ->
    fields = {}
    for own k,v of place
      if k in @InsertableFields
        fields[k] = v
    fields.details = JSON.stringify(place.details)

    @app.insert('place', fields)
    .then (res) =>
      {place_id: res.place_id, name: place.name}

  save: (place) ->
    # Save a modification to DB
    if place.dataSource != 'local' or not place.original?
      throw new Error("PlaceDAO.save must be called on patch data: "+ place)

    # TODO: Would be cool to only write modified fields.
    fields = {}
    for own k,v of place
      if k == 'details'
        fields[k] = ObjectUtil.merge(place.original.details, place.details)
      else if k in @UpdateableFields
        fields[k] = v

    @app.db('place').update(fields).where({place_id:place.place_id})

  modify: (place_id, modifyFunc) ->
    # The callback 'modifyFunc' should take an original 'place' and returns a modified place. 
    # This callback should be a pure function, it might be executued multiple times.

    # Future: Will update this to do concurrency-safe modification.

    @get((query) -> query.where({place_id}))
    .then (places) ->
      if places.length == 0
        return Promise.reject("place ID not found: ", place_id)
      original = places[0]
      modifyFunc(original.startPatch())
    .then (modified) =>
      @save(modified)
      .then ->
        return modified

  modifyMulti: (queryFunc, modifyFunc) ->
    # Fetch a list of place_ids

    modifyOne = (place_id) =>
      @modify(place_id, modifyFunc)

    query = @app.db.select(['place_id']).from('place')
    queryFunc(query)
    query.then (results) ->
      for result in results
        result.place_id
    .map(modifyOne, {concurrency: 1})

provide('PlaceDAO', PlaceDAO)

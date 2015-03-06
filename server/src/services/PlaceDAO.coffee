
class PlaceDAO
  FieldsNotForDB: ['dataSource', 'context', 'original', 'reviews']

  constructor: ->
    @app = depend('App')

  get: (queryModifier) ->
    # queryModifier is a func that takes a Knex query object, and hopefully adds a 'where'
    # clause or something.
    console.log 'get query'
    query = @app.db.select('place_id','name','lat','long','rating','factual_id','details').from('place')
    queryModifier(query)
    query.then (rows) ->
      places = for row in rows
        Place.fromDatabase(row)
      places

  getWithReviews:(placeId) ->
    console.log 'here'
    query = @app.db.select('place.place_id','name','lat','long','rating','factual_id','details',
    'reviewer_name', 'body', 'review_id', 'review.created_at', 'review.updated_at').from('place')
    .leftOuterJoin('review', 'place.place_id', 'review.place_id').where('place.place_id', placeId)
    query.toSQL()
    query.then (rows) ->
      if rows? and rows.length > 0
        place = Place.fromDatabase(rows[0])
        for row in rows
          if row.review_id?
            place.reviews.push Review.fromDatabase(row)
        place

  insert: (place) ->
    fields = {}
    for own k,v of place
      if k in @FieldsNotForDB
        continue
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
      if k in @FieldsNotForDB
        continue
      if k == 'details'
        fields[k] = ObjectUtil.merge(place.original.details, place.details)
      else
        fields[k] = v

    @app.db('place').update(fields).where({place_id:place.place_id})

  modify: (place_id, func) ->
    # The callback 'func' should take an original 'place' and returns a modified place. 
    # This callback should be a pure function, it might be executued multiple times.

    # Future: Will update this to do concurrency-safe modification.
    @get((query) -> query.where({place_id}))
    .then (places) ->
      original = places[0]
      console.log("original = ", original)
      console.log('func = ', func)
      func(original.startPatch())
    .then (modified) =>
      console.log('modified = ', modified)
      @save(modified)

provide('PlaceDAO', PlaceDAO)

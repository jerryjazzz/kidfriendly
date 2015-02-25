
class PlaceDAO
  constructor: ->
    @app = depend('App')

  get: (queryModifier) ->
    # queryModifier is a func that takes a Knex query object, and hopefully adds a 'where'
    # clause or something.

    query = @app.db.select('place_id','name','lat','long','rating','factual_id','details').from('place')
    queryModifier(query)
    query.then (rows) ->
      places = for row in rows
        Place.fromDatabase(row)
      places

  getWithReviews:(placeId) ->
    query = @app.db.select('place.place_id','name','lat','long','rating','factual_id','details',
    'reviewer_name', 'body', 'review_id', 'review.created_at', 'review.updated_at').from('place')
    .leftOuterJoin('review', 'place.place_id', 'review.place_id').where('place.place_id', placeId)
    query.then (rows) ->
      if rows? and rows.length > 0
        place = Place.fromDatabase(rows[0])
        for row in rows
          place.reviews.push Review.fromDatabase(row)
        place

  insert: (place) ->
    fields = {}
    for own k,v of place
      if k in ['dataSource', 'context', 'original']
        continue
      fields[k] = v
    fields.details = JSON.stringify(place.details)

    @app.insert('place', fields)
    .then (res) =>
      {place_id: res.place_id, name: place.name}

  save: (place) ->
    # Save a modification to DB
    if place.dataSource != 'local' or not place.original?
      throw new Error("PlaceDAO.save must be called on patch data")

    # TODO: Would be cool to only write modified fields.
    fields = {}
    for k,v of place
      switch k
        when 'details'
          fields[k] = ObjectUtil.merge(place.original.details, place.details)
        else
          fields[k] = v

    @app.db('place').update(fields).where({place_id:place.place_id})

provide('PlaceDAO', PlaceDAO)

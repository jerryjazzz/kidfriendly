
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

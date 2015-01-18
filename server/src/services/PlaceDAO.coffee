
class PlaceDAO
  constructor: ->
    @app = depend('App')

  get: (queryModifier) ->
    # queryModifier is a func that takes a Knex query object, and hopefully adds a 'where'
    # clause or something.

    query = @app.db.select('place_id','factual_id','details').from('place')
    queryModifier(query)
    query.then (rows) ->
      places = for row in rows
        fields = row
        fields.dataSource = 'db'
        Place.make(fields)
      places

  insert: (place) ->
    fields = {}
    for own k,v of place
      switch k
        when 'dataSource'
        else
          fields[k] = v
    fields.details = JSON.stringify(place.details)

    @app.insert('place', fields)
    .then (res) =>
      {place_id: res.place_id, name: place.name}

  apply: (place, patch) ->
    # Save a modification to DB
    if place.dataSource != 'db'
      throw new Error("PlaceDAO.apply must be called on DB sourced data")

    if patch.dataSource?
      throw new Error("2nd arg of PlaceDAO.apply should be a patch, not Place")

    fields = {}
    for k,v of patch
      switch k
        when 'details'
          fields[k] = ObjectUtil.merge(place.details, patch.details)
        else
          fields[k] = v

    @app.db('place').update(fields).where({place_id:place.place_id})

provide('PlaceDAO', PlaceDAO)

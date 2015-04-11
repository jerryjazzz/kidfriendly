
class ReviewDAO
  constructor: ->
    @app = depend('App')
    @daoCommon = depend('DAOCommon')
    @UpdateableFields = ['body', 'reviewer_name']
    @InsertableFields = @UpdateableFields.concat(['review_id','place_id', 'user_id'])
    @ReadableFields = @InsertableFields
    @modelClass = depend('Review')

  get: (whereFunc) ->
    # whereFunc is a callback that takes a Knex query object, and hopefully adds a 'where'
    # clause or something.
    query = @app.db.select.apply(@ReadableFields).from('review')
    whereFunc(query)
    query.then (rows) =>
      @modelClass.fromDatabase(row) for row in rows

  insert: (review) ->
    fields = {}
    for own k,v of review
      if k in @InsertableFields
        fields[k] = v

    @app.insert('review', fields)
    .then (res) =>
      {review_id: res.review_id, name: review.name}

  save: (review) ->
    # Save a modification to DB
    if review.dataSource != 'local' or not review.original?
      throw new Error("ReviewDAO.save must be called on patch data: "+ review)

    fields = {}
    for own k,v of review
      if k in @UpdateableFields
        fields[k] = v

    @app.db('review').update(fields).where({review_id:review.review_id})
    .then ->
      return review

  modify: (whereFunc, modifyFunc, options) ->
    @daoCommon.modify(this, whereFunc, modifyFunc, options)

provide('ReviewDAO', ReviewDAO)

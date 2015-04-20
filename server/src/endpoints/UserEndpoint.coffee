
class UserEndpoint
  constructor: ->
    @app = depend('App')
    @reviewDao = depend('ReviewDAO')
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    @route = require('express')()

    get @route, '/:user_id/place/:place_id/review', (req) =>
      # SECURITY_TODO: Check auth token

      {user_id, place_id, token} = req.params

      ###
      if not token?
        {statusCode: 400, error: message: 'Token is required'}

      check = new UserAppCheckToken(@app)
      check.start(token)
      ###

      @app.db.select('review_id','place_id','body').from('review').where({user_id,place_id})
        .then (response) ->
          response[0] ? null

    post @route, '/:user_id/place/:place_id/review', (req) =>
      # TODO: Should check that user_id and place_id actually exist.
      # SECURITY_TODO: Check auth token

      {user_id, place_id, token} = req.params

      manualId = req.body.review_id # usually null

      whereFunc = (query) -> query.where({user_id, place_id})
      modifyFunc = (review) ->
        review.review_id = manualId
        review.body = JSON.stringify(req.body.review)
        review.user_id = user_id
        review.place_id = place_id
        review.reviewer_name = req.body.review.name

      @reviewDao.modify(whereFunc, modifyFunc, {allowInsert:true})

    ###
    @route.post '/:user_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      @app.db('users').where(user_id:req.params.user_id).delete()
        .then(-> {})

    @route.post '/new', wrap (req) =>

      if not req.body.email?
        return {statusCode: 400, message: "email is missing from body"}

      manualId = req.body.user_id # usually null

      row =
        user_id: manualId
        email: req.body.email
        created_at: timestamp()
        created_by_ip: req.get_ip()
        source_ver: @app.sourceVersion

      @app.insert('users', row)
      .catch Database.existingKeyError('email'), ->
        {statusCode: 400, error: type: 'email_already_exists'}
    ###

provide('endpoint/api/user', UserEndpoint)

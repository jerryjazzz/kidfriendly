
class UserEndpoint
  constructor: (@app) ->
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/:user_id/place/:place_id/review', wrap (req) =>

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

    @endpoint.post '/:user_id/place/:place_id/review', wrap (req) =>
      {user_id, place_id, token} = req.params

      manualId = req.body.review_id # usually null

      blob = JSON.stringify(req.body.review)

      @app.db.select("review_id").from('review').where({user_id, place_id})
      .then (existing) =>
        if existing[0]?
          @app.db('review').update
            body: blob
            updated_at: DateUtil.timestamp()
          .then -> {review_id: existing[0].review_id}
        else
          @app.insert 'review',
            review_id: manualId
            user_id: user_id
            place_id: place_id
            body: blob
            created_at: DateUtil.timestamp()
            source_ver: @app.sourceVersion
          .then (row) -> {review_id} = row

    ###
    @endpoint.post '/:user_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      @app.db('users').where(user_id:req.params.user_id).delete()
        .then(-> {})

    @endpoint.post '/new', wrap (req) =>

      if not req.body.email?
        return {statusCode: 400, message: "email is missing from body"}

      manualId = req.body.user_id # usually null

      row =
        user_id: manualId
        email: req.body.email
        created_at: DateUtil.timestamp()
        created_by_ip: req.get_ip()
        source_ver: @app.sourceVersion

      @app.insert('users', row)
      .catch Database.existingKeyError('email'), ->
        {statusCode: 400, error: type: 'email_already_exists'}
    ###
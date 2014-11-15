
class UserEndpoint
  constructor: (@app) ->
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/:user_id/place/:place_id/review', wrap (req) =>

      {user_id, place_id} = req.params

      @app.query("select * from review where user_id = ? and place_id = ?", [user_id, place_id])
        .then (response) ->
          response[0] ? null

    @endpoint.post '/:user_id/place/:place_id/review', wrap (req) =>
      {user_id, place_id} = req.params

      manualId = req.body.review_id # usually null

      where = @app.sqlFormat("where user_id = ? and place_id = ?", [user_id, place_id])

      blob = JSON.stringify(req.body.review)

      @app.query("select review_id from review #{where}")
        .then (existing) =>
          if existing[0]?
            @app.query "update review set ? #{where}",
              json: blob
              updated_at: DateUtil.timestamp()
            .then -> {review_id: existing[0].review_id}
          else
            @app.insert "review",
              review_id: manualId
              user_id: user_id
              place_id: place_id
              json: blob
              created_at: DateUtil.timestamp()
              source_ver: @app.sourceVersion
            .then (row) -> {review_id} = row

    @endpoint.post '/:user_id/delete', wrap (req) =>
      # SECURITY_TODO: Verify permission to delete
      @app.query("delete from user where user_id = ?", [req.params.user_id]).then -> {}

    @endpoint.post '/new', wrap (req) =>

      if not req.body.email?
        return {statusCode: 400, message: "email is missing from body"}

      manualId = req.body.id # usually null

      row =
        user_id: manualId
        email: req.body.email
        created_at: DateUtil.timestamp()
        created_by_ip: req.get_ip()
        source_ver: @app.sourceVersion

      # Check for existing email.
      @app.query("select 1 from user where email = ?", [row.email]).then (existingEmail) =>
        if existingEmail.length > 0
          return {statusCode: 400, error: type: 'email_already_exists'}

        @app.insert('user', row)
          .then (row) -> {user_id} = row

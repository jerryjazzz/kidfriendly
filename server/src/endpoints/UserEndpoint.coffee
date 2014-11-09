
class UserEndpoint
  constructor: (@app) ->
    @endpoint = require('express')()

    @endpoint.get '/:user_id/place/:place_id/review', ExpressUtil.wrap {}, (req) =>

      {user_id, place_id} = req.query

      @app.query("select * from review where user_id = ? and place_id = ?", [user_id, place_id])
        .then (response) ->
          if response.length == 0
            return null
          else
            return response[0]

    @endpoint.post '/:user_id/place/:place_id/review', ExpressUtil.wrap {}, (req) =>
      res.status(200).send('todo')

    @endpoint.post '/new', ExpressUtil.wrap {}, (req) =>

      row =
        email: req.body.email
        created_at: DateUtil.timestamp()
        created_by_ip: req.get_ip()
        source_ver: @app.sourceVersion

      # Check for existing email.
      @app.query("select 1 from user where email = ?", [row.email]).then (existingEmail) =>
        if existingEmail.length > 0
          return Promise.reject(statusCode: 400, error: type: 'email_already_exists')

         @app.insert('user', row)

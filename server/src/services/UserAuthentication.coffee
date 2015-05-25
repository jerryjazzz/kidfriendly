
Promise = require('bluebird')

class UserAuthentication

  constructor: ->
    @testUser = depend('TestUser')
    @facebook = depend('Facebook')

  userFromRequest: (req) =>

    if (token = req.query.token)?

      if req.query.token == @testUser.token
        return @testUser.findOrCreate()
      else
        return Promise.reject("'token' not supported yet'")

    else if (facebook_token = req.query.facebook_token)?

      @facebook.validateToken(facebook_token)
      .then (validatedUser) ->
        validatedUser

    else

      Promise.resolve(null)

provide.class(UserAuthentication)


Promise = require('bluebird')

class UserAuthentication

  constructor: ->
    @testUser = depend('TestUser')
    @facebook = depend('Facebook')

  userFromOurToken: (token) ->
    if token == @testUser.token
      @testUser.findOrCreate()
    else
      Promise.reject("'token' not supported yet'")

  userFromFacebookToken: (facebook_token) ->
    @facebook.validateToken(facebook_token)

  fromRequest: (req) =>

    if req.didUserAuthentication?
      return req.user

    user = if (token = req.query.token)?
      @userFromOurToken(token)
    else if (facebook_token = req.query.facebook_token)?
      @userFromFacebookToken(facebook_token)
    else
      Promise.resolve(null)

    user.then ->
      req.didUserAuthentication = true
      req.user = user
      user

provide.class(UserAuthentication)

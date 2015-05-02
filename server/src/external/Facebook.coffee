
passport = require('passport')
FacebookStrategy = require('passport-facebook')

class Facebook
  appId: '***REMOVED***'
  appSecret: '***REMOVED***'

  recentFacebookTokens: {}

  constructor: ->
    @userDao = depend('UserDAO')
    @http = depend('http')

    passportOptions =
      clientID: @appId
      clientSecret: @appSecret

    passport.use new FacebookStrategy passportOptions, (accessToken, refreshToken, profile, done) =>
      @findOrCreateFromPassport(profile)
      .then (user) =>
        @recentFacebookTokens[user.user_id] = accessToken
        done(null, user)
      .catch (err) =>
        done(err)

    passport.serializeUser (user, done) ->
      done(null, user.user_id)

    passport.deserializeUser (id, done) =>
      @userDao.findById(id)
      .then (user) -> done(null, user)
      .catch (err) -> done(err)

  findOrCreateFromPassport: (profile) ->
    email = profile.emails?[0]?.value
    if not email?
      throw new Error("Email not found")

    @userDao.find((query) -> query.where({email}))
    .then (users) =>
      if users.length == 0
        return @createFromPassport(email, profile)

      return users[0]

  createFromPassport: (email, profile) ->
    @userDao.insert
      email: email
      created_at: timestamp()

  validateToken: (token) ->
    url = "https://graph.facebook.com/me?access_token=#{token}"
    @http.request(url: url)
    .then (body) ->
      console.log(body)
      return true

      if body.statusCode != 200
        return false

      data = JSON.parse(body)

    .catch (err) ->
      console.log('Facebook.validateToken err: ', err)
      return false

provide('Facebook', Facebook)

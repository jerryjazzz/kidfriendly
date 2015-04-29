
passport = require('passport')
FacebookStrategy = require('passport-facebook')

class Facebook
  appId: '***REMOVED***'
  appSecret: '***REMOVED***'
  configuredURL: 'https://www.kidfriendlyreviews.com'

  constructor: ->
    @userDao = depend('UserDAO')

    passportOptions =
      clientID: @appId
      clientSecret: @appSecret

    passport.use new FacebookStrategy passportOptions, (accessToken, refreshToken, profile, done) =>
      @findOrCreateFromPassport(profile)
      .then (user) =>
        user.auth.facebook_token = accessToken
        done(null, user)
      .catch (err) =>
        console.log(err)
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
    console.log('creating user with email: ', email)
    @userDao.insert
      email: email
      created_at: timestamp()

provide('Facebook', Facebook)

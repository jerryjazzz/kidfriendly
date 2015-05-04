
passport = require('passport')
FacebookStrategy = require('passport-facebook')

class Facebook
  appId: '***REMOVED***'
  appSecret: '***REMOVED***'

  # map of user_id -> facebook token. These are tokens that we've received through passport
  # oauth. Used for displaying on /admin page
  recentTokenForUser: {}

  tokenValidateCache: {}

  constructor: ->
    @userDao = depend('UserDAO')
    @http = depend('http')

    passportOptions =
      clientID: @appId
      clientSecret: @appSecret

    passport.use new FacebookStrategy passportOptions, (accessToken, refreshToken, profile, done) =>
      @findOrCreateFromPassport(profile)
      .then (user) =>
        @recentTokenForUser[user.user_id] = accessToken
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
        @userDao.insert
          email: email
          created_at: timestamp()
      else
        return users[0]

  validateToken: (token) ->
    url = "https://graph.facebook.com/me?access_token=#{token}"
    @http.request(url: url)
    .then (data) =>
      console.log('validateToken got: ', data)

      if data.error?
        throw data.error

      @findOrCreateFromToken(data)

  findOrCreateFromToken: (data) ->
    @userDao.find((query) -> query.where({facebook_id:data.id}))
    .then (users) =>
      existing = users[0]

      if existing?
        # TODO: Could update user's email here
        return existing

      # No user with matching facebook_id
      # See if we can link it with an existing email

      @userDao.find((query) -> query.where({email:data.email}))
      .then (users) =>
        existing = users[0]
        if existing?
          # Link with existing user
          query = (query) -> query.where(user_id:existing.user_id)
          @userDao.modify query, (user) ->
            user.facebook_id = data.facebook_id

        else
          # Didn't find with email, create new user
          @userDao.insert
            email: data.email
            facebook_id: data.id
            created_at: timestamp()

provide('Facebook', Facebook)

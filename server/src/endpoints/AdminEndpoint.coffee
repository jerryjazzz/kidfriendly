
passport = require('passport')

class AdminEndpoint
  emailWhitelist:
    'andy.fischer@gmail.com': true
    'jrozek@gmail.com': true
    'robbiebell22@yahoo.com': true
    'taylor.r.bell@gmail.com': true

  constructor: ->
    @route = require('express')()
    get = depend('ExpressGet')
    @facebook = depend('Facebook')
    @placeDao = depend('dao/place')
    @voteService = depend('VoteService')
    ExpressUtil = depend('ExpressUtil')

    @route.use(require('cookie-parser')('718473'))
    @route.use(require('express-session')(secret: '718473', resave: false, saveUninitialized: false))
    @route.use(require('passport').initialize())
    @route.use(require('passport').session())

    # These endpoints do not require login
    get @route, '/login-required', ->
      view: 'view/admin/login-required'

    get @route, '/email-not-on-whitelist', (req) ->
      view: 'view/admin/email-not-on-whitelist'
      email: req.user?.email

    get @route, '/logout', (req) ->
      req.logout()
      {
        view: 'view/admin/logged-out'
      }
        
    @route.get '/auth/facebook', passport.authenticate('facebook', {
      callbackURL: '/admin/auth/facebook'
      successRedirect: '/admin'
      failureRedirect: '/admin'
    })

    # Enforce login and check email
    @route.use (req, res, next) =>
      if not req.user? and req.get_ip() == '127.0.0.1'
        req.user = {user_id: 'localhost', email: 'localhost@example.com'}
        return next()

      if not req.user?
        return res.redirect('/admin/login-required')

      email = req.user?.email
      if not @emailWhitelist[email]
        return res.redirect('/admin/email-not-on-whitelist')

      next()

    # Below here, endpoints are only reachable if user is whitelisted.

    get @route, '/', (req) =>
      user = req.user

      if user.toClient?
        user = user.toClient()

      {
        view: 'view/admin/home'
        user: user
        session: req.session
        facebookToken: @facebook.recentTokenForUser[user.user_id]
      }

    get @route, '/fix-zipcodes', (req) =>
      @placeDao.modifyMulti ((query)->query.whereNull('zipcode')), (place) ->
        if place.details.postcode?
          place.zipcode = place.details.postcode

    get @route, '/fix-votes', (req) =>
      @placeDao.modifyMulti (->), (place) =>
        @voteService.recalculate(place)
      .then (results) ->
        {count: results.length}

    for path, obj of depend.multi('admin-endpoint')
      @route.use(path, ExpressUtil.routerFromObject(obj))

provide.class(AdminEndpoint)

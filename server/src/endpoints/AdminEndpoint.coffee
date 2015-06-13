
passport = require('passport')

provide 'AdminEndpoint', ->
  emailWhitelist =
    'andy.fischer@gmail.com': true
    'jrozek@gmail.com': true
    'robbiebell22@yahoo.com': true
    'taylor.r.bell@gmail.com': true

  VoteService = depend('VoteService')
  ExpressUtil = depend('ExpressUtil')
  Facebook = depend('Facebook')

  router = require('express')()

  router.use require('cookie-parser')('718473')
  router.use require('express-session')(secret: '718473', resave: false, saveUninitialized: false)
  router.use require('passport').initialize()
  router.use require('passport').session()

    # These endpoints do not require login
  router.get '/login-required', ExpressUtil.wrapRequestHandler ->
    view: 'view/admin/login-required'

  router.get '/email-not-on-whitelist', ExpressUtil.wrapRequestHandler (req) ->
    view: 'view/admin/email-not-on-whitelist'
    email: req.user?.email

  router.get '/logout', ExpressUtil.wrapRequestHandler (req) ->
    req.logout()
    {
      view: 'view/admin/logged-out'
    }
        
  router.get '/auth/facebook', passport.authenticate('facebook', {
    callbackURL: '/admin/auth/facebook'
    successRedirect: '/admin'
    failureRedirect: '/admin'
  })

    # Enforce login and check email
  router.use (req, res, next) =>
    if not req.user? and req.get_ip() == '127.0.0.1'
      req.user = {user_id: 'localhost', email: 'localhost@example.com'}
      return next()

    if not req.user?
      return res.redirect('/admin/login-required')

    email = req.user?.email
    if not emailWhitelist[email]
      return res.redirect('/admin/email-not-on-whitelist')

    next()

  # Below here, endpoints are only reachable if user is whitelisted.

  router.get '/', ExpressUtil.wrapRequestHandler (req) ->
    user = req.user

    if user.toClient?
      user = user.toClient()

    {
      view: 'view/admin/home'
      user: user
      session: req.session
      facebookToken: Facebook.recentTokenForUser[user.user_id]
    }

  router.get '/fix-zipcodes', ExpressUtil.wrapRequestHandler (req) ->
    Place.modifyMulti ((query)->query.whereNull('zipcode')), (place) ->
      if place.details.postcode?
        place.zipcode = place.details.postcode

  router.get '/fix-votes', ExpressUtil.wrapRequestHandler (req) ->
    Place.modifyMulti (->), (place) =>
      VoteService.recalculate(place)
    .then (results) ->
      {count: results.length}

  for path, obj of depend.multi('admin-endpoint')
    router.use(path, ExpressUtil.routerFromObject(obj))

  router

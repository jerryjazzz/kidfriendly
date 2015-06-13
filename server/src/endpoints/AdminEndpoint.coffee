
passport = require('passport')

provide 'endpoint/admin', ->
  emailWhitelist =
    'andy.fischer@gmail.com': true
    'jrozek@gmail.com': true
    'robbiebell22@yahoo.com': true
    'taylor.r.bell@gmail.com': true

  VoteService = depend('VoteService')
  ExpressUtil = depend('ExpressUtil')
  Facebook = depend('Facebook')

  methods =
    'use': require('cookie-parser')('718473')
    'use': require('express-session')(secret: '718473', resave: false, saveUninitialized: false)
    'use': require('passport').initialize()
    'use': require('passport').session()

    # These endpoints do not require login
    '/login-required': ->
      view: 'view/admin/login-required'

    '/email-not-on-whitelist': (req) ->
      view: 'view/admin/email-not-on-whitelist'
      email: req.user?.email

    '/logout': (req) ->
      req.logout()
      {
        view: 'view/admin/logged-out'
      }
        
    '/auth/facebook': passport.authenticate('facebook', {
      callbackURL: '/admin/auth/facebook'
      successRedirect: '/admin'
      failureRedirect: '/admin'
    })

    # Enforce login and check email
    'use': (req, res, next) =>
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

    '/': (req) ->
      user = req.user

      if user.toClient?
        user = user.toClient()

      {
        view: 'view/admin/home'
        user: user
        session: req.session
        facebookToken: Facebook.recentTokenForUser[user.user_id]
      }

    '/fix-zipcodes': (req) ->
      Place.modifyMulti ((query)->query.whereNull('zipcode')), (place) ->
        if place.details.postcode?
          place.zipcode = place.details.postcode

    '/fix-votes': (req) ->
      Place.modifyMulti (->), (place) =>
        VoteService.recalculate(place)
      .then (results) ->
        {count: results.length}

  for path, obj of depend.multi('admin-endpoint')
    methods['use ' + path] = ExpressUtil.routerFromObject(obj)

  methods

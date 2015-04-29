
passport = require('passport')

class AdminEndpoint
  emailWhitelist:
    'andy.fischer@gmail.com': true

  constructor: ->
    @route = require('express')()
    get = depend('ExpressGet')
    @facebook = depend('Facebook')

    @route.get('/auth/facebook', passport.authenticate('facebook',
      scope: 'email'
      callbackURL: "#{@facebook.configuredURL}/admin/auth/facebook/callback"
    ))

    @route.get('/auth/facebook/callback',
      passport.authenticate('facebook', { successRedirect: '/admin', \
                                          failureRedirect: '/admin' }))

    adminHome = depend('view/admin/home')
    get @route, '/', (req) ->
      presentation: 'view/admin/home'
      user: JSON.stringify(req.user)

provide('endpoint/admin', AdminEndpoint)

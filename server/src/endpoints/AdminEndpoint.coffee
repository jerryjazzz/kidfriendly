
passport = require('passport')

class AdminEndpoint
  constructor: ->
    @route = require('express')()
    get = depend('ExpressGet')
    @facebook = depend('Facebook')

    @route.get('/auth/facebook', passport.authenticate('facebook', scope: 'email'))
    @route.get('/auth/facebook/callback',
      passport.authenticate('facebook', { successRedirect: '/', \
                                          failureRedirect: '/login' }))

    adminHome = depend('view/admin/home')
    get @route, '/', ->
      {presentation: 'view/admin/home'}

provide('endpoint/admin', AdminEndpoint)

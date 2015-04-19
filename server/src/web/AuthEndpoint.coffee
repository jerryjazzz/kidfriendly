
passport = require('passport')

class AuthEndpoint
  constructor: ->
    @route = require('express')()
    get = depend('ExpressGet')
    @facebook = depend('Facebook')

    @route.get('/facebook', passport.authenticate('facebook', scope: 'email'))
    @route.get('/facebook/callback',
      passport.authenticate('facebook', { successRedirect: '/', \
                                          failureRedirect: '/login' }))

provide('AuthEndpoint', AuthEndpoint)

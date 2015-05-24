
Promise = require('bluebird')

class TestEndpoint
  constructor: ->
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    @route = require('express')()
    @testPlace = depend('TestPlace')
    @testUser = depend('TestUser')

    post @route, '/start', (req) =>
      Promise.props
        place: @testPlace.prepare()
        userVotes: @testUser.deleteAllVotes()

    post @route, '/cleanup', (req) =>
      @testUser.deleteAllVotes()

provide('endpoint/api/test', TestEndpoint)

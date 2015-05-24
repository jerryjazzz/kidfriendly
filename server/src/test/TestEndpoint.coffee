
Promise = require('bluebird')

class TestEndpoint
  constructor: ->
    get = depend('ExpressGet')
    post = depend('ExpressPost')
    @route = require('express')()
    @testPlace = depend('TestPlace')
    @testUser = depend('TestUser')
    @voteService = depend('VoteService')

    post @route, '/start', (req) =>
      Promise.props
        place: @testPlace.prepare()
        userVotes: @testUser.deleteAllVotes()
      .then =>
        @voteService.recalculateForPlace('testplace1')

    post @route, '/cleanup', (req) =>
      @testUser.deleteAllVotes()

    post @route, '/delete-votes', (req) =>
      @testUser.deleteAllVotes()

provide.class('endpoint/api/test', TestEndpoint)

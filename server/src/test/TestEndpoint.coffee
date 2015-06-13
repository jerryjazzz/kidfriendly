
Promise = require('bluebird')

provide 'endpoint/api/test', ->
  TestPlace = depend('TestPlace')
  TestUser = depend('TestUser')
  VoteService = depend('VoteService')

  'post /start': (req) ->
    Promise.props
      place: TestPlace.prepare()
      userVotes: TestUser.deleteAllVotes()
    .then =>
      VoteService.recalculateForPlace('testplace1')

  'post /cleanup': (req) ->
    TestUser.deleteAllVotes()

  'post /delete-votes': (req) ->
    TestUser.deleteAllVotes()


helper = require('./TestHelper')
{expect} = require('chai')

describe 'UserVotes', ->

  placeId = helper.testPlaceId
  token = helper.testToken

  before ->
    helper.api.testStart()
  after ->
    helper.api.testCleanup()

  it 'place starts with 0 votes', ->
    helper.api.placeDetails(placeId)
    .then (place) ->
      expect(place.upvote_count ? 0).to.equal(0)
      expect(place.downvote_count ? 0).to.equal(0)

  it 'place shows votes', ->
    helper.api.vote(token, placeId, 1)
    .then ->
      helper.api.placeDetails(placeId)
    .then (place) ->
      expect(place.upvote_count ? 0).to.equal(1)
      expect(place.downvote_count ? 0).to.equal(0)
    .then ->
      helper.api.vote(token, placeId, -1)
    .then ->
      helper.api.placeDetails(placeId)
    .then (place) ->
      expect(place.upvote_count ? 0).to.equal(0)
      expect(place.downvote_count ? 0).to.equal(1)

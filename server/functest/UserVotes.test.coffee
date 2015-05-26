
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

  it 'place shows total votes', ->
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

  it 'place search shows my votes', ->
    helper.api.vote(token, placeId, 1)
    .then ->
      helper.api.searchForTestPlace({token})
    .then (places) ->
      place = places[0]
      expect(place.place_id).to.equal(placeId) # sanity check
      expect(place.me.vote).to.equal(1)
    .then ->
      helper.api.vote(token, placeId, -1)
    .then ->
      helper.api.searchForTestPlace({token})
    .then (places) ->
      place = places[0]
      expect(place.place_id).to.equal(placeId)
      expect(place.me.vote).to.equal(-1)

  it "place search has vote=0 when there's no vote", ->
    helper.api.testDeleteVotes()
    .then ->
      helper.api.searchForTestPlace({token})
    .then (places) ->
      place = places[0]
      expect(place.me?.vote).to.equal(0)

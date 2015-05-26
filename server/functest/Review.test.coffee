

helper = require('./TestHelper')
{expect} = require('chai')

describe 'Review', ->
  token = helper.testToken

  it 'post review', ->
    helper.api.submitReview(helper.testPlaceId, token, {review: {comments: "well, it was pretty good"}})
    .then ->
      helper.api.getReview(helper.testPlaceId, token)
    .then (result) ->
      expect(result.body.comments).to.equal("well, it was pretty good")


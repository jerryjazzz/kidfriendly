
helper = require('./TestHelper')
{expect} = require('chai')

describe 'Place', ->
  place = null

  before ->
    helper.api.anyPlace().then (p) ->
      place = p

  it '/place/any', ->
    helper.assertPlace(place)

  it '/place/details/review', ->
    helper.api.placeDetails(place.place_id)
    .then (details) ->
      helper.assertPlace(details)
      expect(details.place_id).to.equal(place.place_id)
      expect(details.reviews).to.exist()

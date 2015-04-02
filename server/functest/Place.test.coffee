
helper = require('./TestHelper')
{expect} = require('chai')

describe 'Place', ->
  samplePlace = null

  it '/place/any', ->
    helper.api.anyPlace()
    .then (place) ->
      samplePlace = place
      helper.assertPlace(place)
      console.log('/place/any returned place_id: ', place.place_id)

  it '/place/details', ->
    helper.api.placeDetails(samplePlace.place_id)
    .then (place) ->
      helper.assertPlace(place)
      expect(place.place_id).to.equal(samplePlace.place_id)

  it '/place/details/review', ->
    helper.api.placeDetails(samplePlace.place_id)
    .then (place) ->
      helper.assertPlace(place)
      expect(place.place_id).to.equal(samplePlace.place_id)
      expect(place.reviews).to.exist()

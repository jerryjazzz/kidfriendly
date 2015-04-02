

helper = require('./TestHelper')
{expect} = require('chai')

describe 'Review', ->
  samplePlace = null
  testUserId = null

  it '/place/any', ->
    helper.api.anyPlace()
    .then (place) ->
      samplePlace = place

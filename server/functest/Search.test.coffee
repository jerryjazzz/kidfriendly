
helper = require('./TestHelper')
{assert, expect} = require('chai')

describe 'Search', ->
  it 'finds places in 85260 zip code', ->
    helper.api.search(zipcode: 85260)
    .then (results) ->
      assert(results.length > 0)

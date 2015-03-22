"use strict"

Place = require('kfly_server').depend('Place')
{assert, expect} = require('chai')

describe 'Place', ->
  describe 'make', ->
    it 'parses JSON', ->
      place = Place.make({place_id: 123, name: "Moe's", details: '{"hours": 1}'})
      assert(place.place_id == 123)
      assert(place.details.hours == 1)

  describe 'fromDatabase', ->
    it 'creates a frozen value', ->
      place = Place.fromDatabase({place_id: 123, name: "Moe's", details: '{"hours": 1}'})
      fn = ->
        place.anotherField = 1
      expect(fn).to.throw(Error)

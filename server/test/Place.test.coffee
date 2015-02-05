"use strict"

{Place} = require('./../build/kfly_server.js')
{assert, expect} = require('chai')

describe 'Place', ->
  describe 'make', ->
    it 'parses JSON', ->
      place = Place.make({place_id: 123, name: "Moe's", details: '{"hours": 1}'})
      assert(place.place_id == 123)
      assert(place.details.hours == 1)

    it 'creates a frozen value', ->
      place = Place.make({place_id: 123, name: "Moe's", details: '{"hours": 1}'})
      fn = ->
        place.anotherField = 1
      expect(fn).to.throw(Error)

  describe 'with patch', ->
    it 'works', ->
      place = Place.make({place_id: 123, name: "Moe's", rating: 40})
      patch = {name: "Chez Moe", rating: 80}
      place = place.withPatch(patch)
      assert(place instanceof Place)
      assert(place.rating == 80)
      assert(place.name == "Chez Moe")

    it "merges the contents of 'details'", ->
      place = Place.make({place_id: 123, name: "Moe's", details: {kids_menu: true}})
      patch = {details: {adults_menu: true}}
      place = place.withPatch(patch)
      assert(place.details.kids_menu)
      assert(place.details.adults_menu)

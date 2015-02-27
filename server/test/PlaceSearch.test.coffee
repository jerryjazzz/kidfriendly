
{depend} = require('./TestCommon')
{expect} = require('chai')

describe 'PlaceSearch', ->
  placeSearch = depend('PlaceSearch')
  describe 'pointsForDistance', ->
    it 'does good mathing', ->
      expect(placeSearch.pointsForDistance(0)).equals(0)
      expect(placeSearch.pointsForDistance(5000)).equals(0)
      expect(placeSearch.pointsForDistance(6000)).equals(-2)
      expect(placeSearch.pointsForDistance(8000)).equals(-6)
      expect(placeSearch.pointsForDistance(10000)).equals(-10)
      expect(placeSearch.pointsForDistance(15000)).equals(-13)
      expect(placeSearch.pointsForDistance(20000)).equals(-15)

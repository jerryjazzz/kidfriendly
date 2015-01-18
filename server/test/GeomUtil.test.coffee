
{GeomUtil} = require('./../build/kfly_server.js')
{assert} = require('chai')

describe 'GeomUtil', ->
  describe 'getBounds', ->
    it 'returns correctly', ->
      bounds = GeomUtil.getBounds({lat: 20, long: 100, meters: 1000})
      for lat in [bounds.lat1, bounds.lat2]
        assert(lat > 19)
        assert(lat < 21)
      for long in [bounds.long1, bounds.long2]
        assert(long > 99)
        assert(long < 101)

      assert(bounds.lat1 < bounds.lat2)
      assert(bounds.long1 < bounds.long2)

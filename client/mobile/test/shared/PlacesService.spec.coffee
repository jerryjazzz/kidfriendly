'use strict'
describe 'PlacesService', ->

  service = {}

  beforeEach ->
    module 'kf.shared'

    inject ($injector) ->
      service = $injector.get('placesService')

  describe 'getPlace', ->
    it 'should return a place', ->
#      expect(service).toBeDefined()
#      place = service.getPlace("9283")
#      expect(place).toBeDefined()
#      expect(place.name).toEqual('Hello Pizza')

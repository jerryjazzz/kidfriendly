'use strict'
describe 'PlacesService', ->

  service = {}
  $httpBackend = {}
  position = {}
  searchResponse = [
    {place_id: "2958", name: "Joe's Pizza", addr: "42 Pizza Way, Scottsdale", location:"33.526116,-111.925424", thumbnail_url: "https://lh4.googleusercontent.com/-9c4TjXE17oM/U7Wd2nY0XpI/AAAAAAAA19I/Fkd6zm0hMsE/w88-h88-p/photo.jpg", rating:55}
    {place_id: "3859", name: "Party Pie", addr: "5447 Thomas Road, Scottsdale ", location: "33.526116,-111.925424", thumbnail_url: "https://lh6.googleusercontent.com/-w30do65Me-w/U0RGkDJJsyI/AAAAAAAAq_o/zwuikUyF_6g/w88-h88-p/photo.jpg", rating:34}
    {place_id: "9831", name: "Pizza all The way", addr: "321  Main St Scottsdale", location: "33.526116,-111.925424", thumbnail_url:"https://lh3.googleusercontent.com/-CsA7u0NKdSM/VCXIicXc0hI/AAAAAAABDoc/TaiWHhvbjTU/w88-h88-p/photo.jpg", rating:89}
  ]

  detailResponse =
    place_id: "2958"
    name: "Joe's Pizza"
    addr: "42 Pizza Way, Scottsdale"
    location:"33.526116,-111.925424"
    thumbnail_url: "https://lh4.googleusercontent.com/-9c4TjXE17oM/U7Wd2nY0XpI/AAAAAAAA19I/Fkd6zm0hMsE/w88-h88-p/photo.jpg"
    rating:55

  beforeEach ->
    module 'kf.shared'

    module ($provide) ->
      position =
        coords:
          latitude: 102.2
          longitude: 111.1

      promiseSpy = jasmine.createSpyObj 'promise', ['then']
      promiseSpy.then = (fn) -> fn(position)

      locationService =
        getPosition: -> promiseSpy
        calculateDistance: -> .5

      $provide.value 'locationService', locationService
      return

    inject ($injector) ->
      service = $injector.get('placesService')
      $httpBackend = $injector.get '$httpBackend'
      service.searchResults = searchResponse

  afterEach ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()

  describe 'getPlace', ->
    it 'should return a place', ->
      expect(service).toBeDefined()
      place = service.getPlace("3859")
      expect(place).toBeDefined()
      expect(place.name).toEqual('Party Pie')

  describe 'search', ->
    it 'should make http request with keyword and location', ->
      keyword = 'pizza'

      $httpBackend.expectGET "http://kidfriendlyreviews.com/api/search/nearby?type=restaurant&location=#{position.coords.latitude},#{position.coords.longitude}&keyword=#{keyword}"
      .respond 200, searchResponse
      promise = service.search(keyword, position)
      promise.then (results) -> expect(results.length).toEqual 3
      $httpBackend.flush()


  describe 'getPlaceDetail', ->
    it 'should make request for a place', ->
      id = "123"
      $httpBackend.expectGET "http://kidfriendlyreviews.com/api/place/#{id}/details"
      .respond 200, detailResponse
      promise = service.getPlaceDetail(id).then (result) =>
        expect(result).toEqual(detailResponse)
      $httpBackend.flush()
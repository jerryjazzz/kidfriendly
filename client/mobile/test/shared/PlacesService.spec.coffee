'use strict'
describe 'PlacesService', ->

  service = {}
  $httpBackend = {}
  position = {}
  locationService ={}
  searchResponse = [
    {place_id: "2958", name: "Joe's Pizza", addr: "42 Pizza Way, Scottsdale", lat:"33.526116", long:"-111.925424", thumbnail_url: "https://lh4.googleusercontent.com/-9c4TjXE17oM/U7Wd2nY0XpI/AAAAAAAA19I/Fkd6zm0hMsE/w88-h88-p/photo.jpg", rating:55}
    {place_id: "3859", name: "Party Pie", addr: "5447 Thomas Road, Scottsdale ", lat: "33.526116", long:"-111.925424", thumbnail_url: "https://lh6.googleusercontent.com/-w30do65Me-w/U0RGkDJJsyI/AAAAAAAAq_o/zwuikUyF_6g/w88-h88-p/photo.jpg", rating:34}
    {place_id: "9831", name: "Pizza all The way", addr: "321  Main St Scottsdale", lat: "33.526116", long:"-111.925424", thumbnail_url:"https://lh3.googleusercontent.com/-CsA7u0NKdSM/VCXIicXc0hI/AAAAAAABDoc/TaiWHhvbjTU/w88-h88-p/photo.jpg", rating:89}
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

  describe 'search', ->
    it 'should make http request with zipcode', ->
      keyword = '85260'

      $httpBackend.expectGET "http://@@kfUri/api/search/nearby?type=restaurant&zipcode=#{keyword}"
      .respond 200, searchResponse
      promise = service.search(keyword, position)
      promise.then (results) -> expect(results.length).toEqual 3
      $httpBackend.flush()

    it 'should make http request with location', ->
      keyword = 'nearby'
      $httpBackend.expectGET "http://@@kfUri/api/search/nearby?type=restaurant&lat=#{position.latitude}&long=#{position.longitude}"
      .respond 200, searchResponse
      promise = service.search(keyword, position)
      promise.then (results) -> expect(results.length).toEqual 3
      $httpBackend.flush()

  it 'should return results even when no position available', ->
      promiseSpy = jasmine.createSpyObj 'promise', ['then']
      promiseSpy.then = (fn) -> fn(undefineds)

      locationService.getPosition = -> promiseSpy
      keyword = 'nearby'

      $httpBackend.expectGET "http://@@kfUri/api/search/nearby?type=restaurant&lat=#{position.latitude}&long=#{position.longitude}"
      .respond 200, searchResponse
      promise = service.search(keyword, position)
      promise.then (results) -> expect(results.length).toEqual 3
      $httpBackend.flush()


  describe 'getPlaceDetail', ->
    it 'should make request for a place', ->
      id = "123"
      $httpBackend.expectGET "http://@@kfUri/api/place/#{id}/details/reviews"
      .respond 200, detailResponse
      promise = service.getPlaceDetail(id).then (result) =>
        expect(result).toEqual(detailResponse)
      $httpBackend.flush()

  describe 'calculateScore', ->
    it 'should calculate a score for a review', ->
      review =
        body:
          kidsMenu: 4.5
          healthOptions: 3
          accommodations: 2.5
          service: 1.1
      service.calculateScore(review)
      expect(review.score).toEqual(59.4)
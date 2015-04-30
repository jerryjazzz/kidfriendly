'use strict'

describe 'DetailsCtrl', ->
  scope = {}
  analyticsService = {}
  placesService = {}
  $window = {}
  place = {}
  ctrl = {}
  beforeEach ->
    module 'Mobile'
    module 'kf.shared'


    inject (_$controller_, $rootScope, _$window_, _analyticsService_) ->
      scope = $rootScope.$new()
      analyticsService = _analyticsService_
      $window = _$window_
      placesService.calculateScore = (review) -> 33
      place =
        name: "Joes place"
        reviews: ['dummy1', 'dummy2']
      spyOn(placesService, 'calculateScore')

      _$controller_ 'DetailsCtrl',
        $scope:scope
        place:place
        placesService: placesService
        analyticsService:analyticsService
        $window:$window


  describe 'constructor', ->
    it 'should define ctrl', ->
      expect(ctrl).toBeDefined()

    it 'should calulate scores', ->
      expect(placesService.calculateScore).toHaveBeenCalled()

  describe '$scope', ->
    it 'should make call using $window', ->
      spyOn($window, 'open')
      phone ="4803239651"
      scope.makeCall phone
      expect($window.open).toHaveBeenCalledWith("tel:#{phone}")

    it 'should toggle map', ->
      expect(scope.data.mapVisible).toBeFalsy()
      expect(scope.data.mapStyle["button-dark"]).toBeTruthy()
      expect(scope.data.mapStyle["button-selected"]).toBeFalsy()
      scope.toggleMap()
      expect(scope.data.mapVisible).toBeTruthy()
      expect(scope.data.mapStyle["button-dark"]).toBeFalsy()
      expect(scope.data.mapStyle["button-selected"]).toBeTruthy()
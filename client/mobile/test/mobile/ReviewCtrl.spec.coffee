#'use strict'
#
#describe 'ReviewCtrl', ->
#  scope = {}
#  $controller = {}
#  stateParams = {}
#  placesService = {}
#  beforeEach ->
#    module 'Mobile'
#    module 'kf.shared'
#
#
#    inject (_$controller_, $rootScope) ->
#      scope = $rootScope.$new()
#      $controller = _$controller_
#      stateParams.placeId = "24"
#      placesService.getPlace = (id) ->
#        {id:id, name:"test name"}
#
#  describe 'constructor', ->
#    it 'controller should be defined', ->
#      ctrl = $controller 'ReviewCtrl',
#        $scope:scope
#        $stateParams:stateParams
#        placesService: placesService
#
#      expect(ctrl).toBeDefined()
#      place = scope.place
#      expect(place).toBeDefined()
#      expect(place.name).toEqual('test name')
#      expect(place.id).toEqual('24')
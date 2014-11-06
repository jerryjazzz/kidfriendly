'use strict'

describe 'ReviewCtrl', ->
  scope = {}
  $controller = {}

  beforeEach ->
    module 'Mobile'

    inject (_$controller_, $rootScope) ->
      scope = $rootScope.$new()
      $controller = _$controller_

  describe 'constructor', ->
    it 'controller should be defined', ->
      ctrl = $controller 'ReviewCtrl',
        $scope:scope

      expect(ctrl).toBeDefined()
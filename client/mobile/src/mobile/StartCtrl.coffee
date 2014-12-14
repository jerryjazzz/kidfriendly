'use strict'
class StartCtrl
  constructor: (@locationService) ->
    @locationService.fetchPosition()

StartCtrl.$inject = ['locationService']
angular.module('Mobile').controller 'StartCtrl', StartCtrl
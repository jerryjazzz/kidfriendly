'use strict'

###*
 # @ngdoc function
 # @name webApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the webApp
###
angular.module('webApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]

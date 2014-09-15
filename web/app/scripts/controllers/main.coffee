'use strict'

###*
 # @ngdoc function
 # @name webApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the webApp
###
angular.module('webApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]

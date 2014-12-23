'use strict'

###*
 # @ngdoc function
 # @name dashboardApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the dashboardApp
###
angular.module('dashboardApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]

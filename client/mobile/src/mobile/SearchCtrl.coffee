'use strict'
class SearchCtrl
  constructor:($scope, $state)->
    $scope.performSearch = =>
      $state.go('results')

SearchCtrl.$inject = ['$scope', '$state']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl
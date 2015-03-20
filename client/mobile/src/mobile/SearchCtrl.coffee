'use strict'
class SearchCtrl
  constructor:($scope, $stateParams, results)->
    $scope.results = results

SearchCtrl.$inject = ['$scope', '$stateParams', 'results']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl
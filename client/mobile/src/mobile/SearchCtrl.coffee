'use strict'
class SearchCtrl
  constructor:($scope, $state, placesService)->
    $scope.performSearch = (keyword)=>
      console.log 'how about here'
      placesService.search(keyword).then -> $state.go('results')


SearchCtrl.$inject = ['$scope', '$state', 'placesService']
angular.module('Mobile').controller 'SearchCtrl', SearchCtrl
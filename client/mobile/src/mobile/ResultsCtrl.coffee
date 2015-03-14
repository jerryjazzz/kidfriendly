'use strict'
class ResultsCtrl
  constructor:(@$scope, @placesService)->
    @$scope.searchResults = @placesService.searchResults
    @$scope.openText = @_openText

ResultsCtrl.$inject = ['$scope', 'placesService']
angular.module('Mobile').controller 'ResultsCtrl', ResultsCtrl
'use strict'
class ResultsCtrl
  constructor:(@$scope, @placesService)->
    @$scope.searchResults = @placesService.searchResults

  _getStarSequence: (stars) ->
    sequence = []
    for num in [1..5]
      if (num <= stars)
        sequence.push({id:num, value:"ion-ios7-star"})
      else if (num == Math.ceil(stars))
        sequence.push({id:num, value:"ion-ios7-star-half"})
      else
        sequence.push({id:num, value:"ion-ios7-star-outline"})
    sequence

ResultsCtrl.$inject = ['$scope', 'placesService']
angular.module('Mobile').controller 'ResultsCtrl', ResultsCtrl

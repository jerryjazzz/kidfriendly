'use strict'
class ReviewService
  constructor:($http) ->
    @reset()

  reset: ->
    @surveyResults = {}

ReviewService.$inject = ['$http']
angular.module('kf.shared').service 'reviewService', ReviewService
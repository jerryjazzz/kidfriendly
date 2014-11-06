'use strict'
class ReviewCtrl
  constructor:($scope)->
    @test = 'test'

ReviewCtrl.$inject = ['$scope']

angular.module('Mobile').controller('ReviewCtrl', ReviewCtrl)
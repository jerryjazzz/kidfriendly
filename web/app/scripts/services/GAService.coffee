'use strict'
class GAService
  constructor: ($window) ->return $window.ga

GAService.$inject = ['$window']

angular.module('web').service 'gaService', GAService
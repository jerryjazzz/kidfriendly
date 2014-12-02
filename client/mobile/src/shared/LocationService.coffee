'use strict'
class LocationService
  constructor:(@$cordovaGeolocation)->

  getPosition: ->
    @$cordovaGeolocation.getCurrentPosition()


LocationService.$inject = ['$cordovaGeolocation']
angular.module('kf.shared').service 'locationService', LocationService
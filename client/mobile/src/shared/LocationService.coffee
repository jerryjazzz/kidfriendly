'use strict'
class LocationService
  constructor:(@$ionicPlatform, @$cordovaGeolocation, @$q)->

  fetchPosition: ->
    deferred = @$q.defer()
    @$ionicPlatform.ready =>
      @$cordovaGeolocation.getCurrentPosition({timeout:10000, maximumAge:300000}).then (position) =>
        deferred.resolve(position)
      , (reason) =>
        deferred.reject("Could not get position: #{reason}")
    deferred.promise

LocationService.$inject = ['$ionicPlatform', '$cordovaGeolocation', '$q']
angular.module('kf.shared').service 'locationService', LocationService
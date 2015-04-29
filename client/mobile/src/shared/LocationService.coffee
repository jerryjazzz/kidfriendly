'use strict'
class LocationService
  constructor:(@$ionicPlatform, @$cordovaGeolocation, @$q)->

  fetchPosition: ->
    deferred = @$q.defer()
    @$ionicPlatform.ready =>
      @$cordovaGeolocation.getCurrentPosition({timeout:5000, maximumAge:60000}).then (position) =>
        console.log 'position', position
        deferred.resolve(position)
      , (reason) =>
        console.log 'reject', reason
        deferred.resolve(undefined)
    deferred.promise

LocationService.$inject = ['$ionicPlatform', '$cordovaGeolocation', '$q']
angular.module('kf.shared').service 'locationService', LocationService
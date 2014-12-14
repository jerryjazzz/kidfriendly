'use strict'
class LocationService
  constructor:(@$cordovaGeolocation, @$q)->
    @cachedPosition

  fetchPosition: ->
    deferred = @$q.defer()
    @$cordovaGeolocation.getCurrentPosition().then (position) =>
      @cachedPosition = position
      deferred.resolve(position)
    deferred.promise


  calculateDistance:(from, to) ->
    R = 6371 # km
    dLat = @_deg2rad(to.latitude - from.latitude)
    dLon = @_deg2rad(to.longitude - from.longitude)
    lat1 = @_deg2rad(from.longitude)
    lat2 = @_deg2rad(to.longitude)
    a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    d = R * c * 0.621371
    d

  _deg2rad:(deg) ->
    deg * (Math.PI/180)

LocationService.$inject = ['$cordovaGeolocation', '$q']
angular.module('kf.shared').service 'locationService', LocationService
'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout, @locationService, @kfUri, @geolib)->
  search:(keyword, position) ->
    deferred = @$q.defer()
    @$http.get("//#{@kfUri}/api/search/nearby?type=restaurant&lat=#{position.coords.latitude}&long=#{position.coords.longitude}&keyword=#{keyword}").success (data) =>
      @searchResults = data
      for result in @searchResults
        result.distance = @geolib.getDistance(position.coords,
          {latitude:parseFloat(result.lat, 10), longitude:parseFloat(result.long, 10)}
        )
        result.distance = Math.round(result.distance * 0.000621371 * 10) / 10
      deferred.resolve(@searchResults)
    deferred.promise


  getPlace: (id) ->
    return result for result in @searchResults when result.place_id == id
    return null

  getPlaceDetail:(id) ->
    deferred = @$q.defer()
    @$http.get("//#{@kfUri}/api/place/#{id}/details/reviews").success (data) =>
      @currentPlace = data
      deferred.resolve(data)
    deferred.promise

  getCurrentPlace:->
    @currentPlace

  submitReview: (userId, placeId, review) ->
    deferred = @$q.defer()
    @$http.post("//#{@kfUri}/api/user/#{userId}/place/#{placeId}/review", {review:review})
    .success (data) =>
      deferred.resolve()
    .error (error) =>
      deferred.reject("Error saving review")

PlacesService.$inject = ['$http', '$q', '$timeout', 'locationService', 'kfUri', 'geolib']
angular.module('kf.shared').service 'placesService', PlacesService
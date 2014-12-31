'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout, @locationService)->

  search:(keyword, position) ->
    deferred = @$q.defer()
    @$http.get("http://kidfriendlyreviews.com/api/search/nearby?type=restaurant&location=#{position.coords.latitude},#{position.coords.longitude}&keyword=#{keyword}").success (data) =>
      @searchResults = data
      for result in @searchResults
        result.distance = @locationService.calculateDistance position.coords,
          latitude:parseFloat(result.location.split(',')[0], 10)
          longitude:parseFloat(result.location.split(',')[1], 10)
        result.distance = Math.round(result.distance * 10 *1.5) / 10
      deferred.resolve(@searchResults)
    deferred.promise

  getPlace: (id) ->
    return result for result in @searchResults when result.place_id == id
    return null

  getPlaceDetail:(id) ->
    deferred = @$q.defer()
    @$http.get("http://kidfriendlyreviews.com/api/place/#{id}/details").success (data) =>
      @currentPlace = data
      deferred.resolve(data)
    deferred.promise

  getCurrentPlace:->
    @currentPlace

  submitReview: (userId, placeId, review) ->
    deferred = @$q.defer()
    @$http.post("http://kidfriendlyreviews.com/api/user/#{userId}/place/#{placeId}/review", review)
    .success (data) =>
      deferred.resolve()
    .error (error) =>
      deferred.reject("Error saving review")

PlacesService.$inject = ['$http', '$q', '$timeout', 'locationService']
angular.module('kf.shared').service 'placesService', PlacesService
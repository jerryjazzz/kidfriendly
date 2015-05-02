'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout, @locationService, @kfUri, @geolib)->

  httpGet: (path) ->
    url = "http://#{@kfUri}" + path
    @$http.get(url, headers: {Accept: 'application/json'})

  httpPost: (path) ->
    url = "http://#{@kfUri}" + path
    @$http.post(url, headers: {Accept: 'application/json'})

  search:(keyword, position) ->
    deferred = @$q.defer()
    url = @createUrl(keyword, position)
    @httpGet(url).success (data) =>
      @searchResults = data
      @calculateDistance(data, position) if position?
      deferred.resolve(@searchResults)
    .error (reason) ->
      deferred.resolve []
    deferred.promise

  createUrl:(keyword, position) ->
    url = "/api/search/nearby?type=restaurant"
    if keyword == 'nearby'
      url = "#{url}&lat=#{position.latitude}&long=#{position.longitude}"
    else
      url = "#{url}&zipcode=#{keyword}"
#    "#{url}&meters=#{10000}"

  calculateDistance:(data, position) ->
    for result in data
      result.distance = @geolib.getDistance(position,
        {latitude:parseFloat(result.lat, 10), longitude:parseFloat(result.long, 10)}
      )
      result.distance = Math.round(result.distance * 0.000621371 * 10) / 10

  calculateScore: (review) ->
    review.score =
      review.body.kidsMenu * 6 +
      review.body.healthOptions * 6 +
      review.body.accommodations * 4 +
      review.body.service * 4
    review

  getPlaceDetail:(id) ->
    deferred = @$q.defer()
    @httpGet("/api/place/#{id}/details/reviews").success (data) =>
      @currentPlace = data
      deferred.resolve(data)
    deferred.promise

  getCurrentPlace:->
    @currentPlace

  submitReview: (userId, placeId, review) ->
    deferred = @$q.defer()
    @httpPost("/api/user/#{userId}/place/#{placeId}/review", {review:review})
    .success (data) =>
      deferred.resolve()
    .error (error) =>
      deferred.reject("Error saving review")

PlacesService.$inject = ['$http', '$q', '$timeout', 'locationService', 'kfUri', 'geolib']
angular.module('kf.shared').service 'placesService', PlacesService

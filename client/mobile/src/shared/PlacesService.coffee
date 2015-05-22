'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout, @locationService, @kfUri, @geolib, @userService)->

  httpGet: (path) ->
    url = "http://#{@kfUri}" + path
    @$http.get(url, headers: {Accept: 'application/json'})

  httpPost: (path, body) ->
    url = "https://#{@kfUri}" + path
    @$http.post(url, body, headers: {Accept: 'application/json'})

  search:(keyword, position) ->
    deferred = @$q.defer()
    url = @createUrl(keyword, position)
    @httpGet(url).success (data) =>
      @searchResults = data
      @calculateDistances(data, position) if position?
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

  calculateDistances:(data, position) ->
    @calculateSingleDistance(result, position) for result in data

  calculateSingleDistance: (result, position) ->
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

  getPlaceDetail:(id, position) ->
    deferred = @$q.defer()
    @httpGet("/api/place/#{id}/details/reviews").success (data) =>
      @calculateSingleDistance(data, position) if position
      @currentPlace = data
      deferred.resolve(data)
    deferred.promise

  getCurrentPlace:->
    @currentPlace

  submitReview: (placeId, review) ->
    deferred = @$q.defer()
    @userService.getUser().then (user) =>
      console.log 'what do we have here', user
      if user.isAuthenticated()
        console.log 'user is authed read to submit review'
        @httpPost("/api/user/me/place/#{placeId}/review?facebook_token=#{user.accessToken}", {review:review})
        .success (data) =>
          console.log 'success', data
          deferred.resolve()
        .error (error) =>
          console.log 'error', error
          deferred.reject("Error saving review")
      else
        console.log 'user not authed'
        deferred.reject("User not authenticated")
    deferred.promise

PlacesService.$inject = ['$http', '$q', '$timeout', 'locationService', 'kfUri', 'geolib', 'userService']
angular.module('kf.shared').service 'placesService', PlacesService
'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout, @locationService)->

  search:(keyword) ->
    deferred = @$q.defer()
    @locationService.getPosition().then (position) =>
      console.log 'got here', position
      @$http.get("http://kidfriendlyreviews.com/api/search/nearby?type=restaurant&location=#{position.coords.latitude},#{position.coords.longitude}&keyword=#{keyword}").success (data) =>
        @results = data
        deferred.resolve(@results)
    deferred.promise

  getPlace: (id) ->
    return result for result in @results when result.place_id == id
    return null

PlacesService.$inject = ['$http', '$q', '$timeout', 'locationService']
angular.module('kf.shared').service 'placesService', PlacesService
'use strict'
class PlacesService
  constructor:(@$http, @$q, @$timeout)->
    @results = [
      {place_id: "2958", name: "Joe's Pizza", addr: "42 Pizza Way, Scottsdale", distance:".2 mi", thumbnail_url: "https://lh4.googleusercontent.com/-9c4TjXE17oM/U7Wd2nY0XpI/AAAAAAAA19I/Fkd6zm0hMsE/w88-h88-p/photo.jpg", rating:55}
      {place_id: "3859", name: "Party Pie", addr: "5447 Thomas Road, Scottsdale ", distance: "1.2 mi", thumbnail_url: "https://lh6.googleusercontent.com/-w30do65Me-w/U0RGkDJJsyI/AAAAAAAAq_o/zwuikUyF_6g/w88-h88-p/photo.jpg", rating:34}
      {place_id: "9831", name: "Pizza all The way", addr: "321  Main St Scottsdale", distance: "3 mi", thumbnail_url:"https://lh3.googleusercontent.com/-CsA7u0NKdSM/VCXIicXc0hI/AAAAAAABDoc/TaiWHhvbjTU/w88-h88-p/photo.jpg", rating:89}
      {place_id: "2112", name: "Papa Dan's", addr: "1 Pizza Blvd Scottsdale", distance: "3.4 mi", thumbnail_url:"https://lh5.googleusercontent.com/-PJkwOSrCtfI/U1fqVCExFyI/AAAAAAAArbQ/8gdHza5_3Bs/w88-h88-p/photo.jpg", rating:90}
      {place_id: "7503", name: "Saucy Slice ", addr: "710 Park Ave Phoenix", distance: "4 mi", thumbnail_url:"https://lh3.googleusercontent.com/-yID3u_kWWXs/T6Q8I4aj8ZI/AAAAAAAAAEI/z9BxugJsYLw/w88-h88-p/Domino%27s%2BPizza", rating:92}
      {place_id: "9283", name: "Hello Pizza", addr: "589 Arizona Place Phoenix", "4 mi", thumbnail_url:"https://geo0.ggpht.com/cbk?cb_client=maps_sv.tactile&output=thumbnail&thumb=2&panoid=Cnt9Ojd_FCrQqXhZnjbBXg&w=88&h=88&yaw=184&pitch=0&ll=33.500718%2C-111.923294", rating:15}
    ]

#    {"place_id":"39675283","name":"Pizzeria Bianco","location":"33.449212,-112.065634","icon":"http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png","open_now":true}

  search:(keyword) ->
    deferred = @$q.defer()

#    @$timeout =>
#      deferred.resolve('test')
#    , 10
#    deferred.promise
#
    console.log 'keyword', keyword
    @$http.get("http://kidfriendlyreviews.com/api/search/nearby?type=restaurant&location=33.4941700,-111.9260520&keyword=#{keyword}").success (data) =>
      @results = data
      console.log data
      deferred.resolve(@results)

    deferred.promise

  getPlace: (id) ->
    return result for result in @results when result.place_id == id
    return null

PlacesService.$inject = ['$http', '$q', '$timeout']
angular.module('kf.shared').service 'placesService', PlacesService
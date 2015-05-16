'use strict'
class UserService
  constructor: (@$http, @$q, @$cordovaFacebook, @$window, @kfUri, @$rootScope, @$timeout)->
    @user = angular.fromJson @$window.localStorage.getItem("user")
    if not @user? then @user = {authenticated:no}

  httpGet: (path) ->
    url = "http://#{@kfUri}" + path
    @$http.get(url, headers: {Accept: 'application/json'})

  getUser: ->
    defer = @$q.defer()
    if @user?.facebookToken?
      @httpGet("/api/user/me?facebook_token=#{token}").success (data) =>
        console.log 'data', data
        defer.resolve(data)
      .error (error) =>
        console.log 'error', error
        defer.resolve(@user)
    else
      @$timeout => defer.resolve(@user)
    defer.promise

  getUserForToken: (token) ->
    defer = @$q.defer()
    @httpGet("/api/user/me?facebook_token=#{token}").success (data) =>
      console.log 'data', data
      defer.resolve(data)
    .error (error) =>
      console.log 'error', error
      defer.reject(error)
    defer.promise

  loginOrSignUp: ->
    defer = @$q.defer()
    @$cordovaFacebook.login (["public_profile", "email", "user_friends"])
    .then (success) =>
      console.log 'success: ', success
      @getUserForToken(success.authResponse.accessToken)
      @user.id = success.authResponse.userID
      @user.authenticated = yes
      @$window.localStorage.setItem('user', angular.toJson @user)
      @$rootScope.$broadcast '$authenticationSuccess', @user
      defer.resolve @user

    , (error) =>
      console.log error
      defer.reject(error)
    defer.promise

  logout: ->
    @$window.localStorage.removeItem('user')
    @user.firstName = undefined
    @user.lastName = undefined
    @user.accessToken = undefined
    @user.id = undefined
    @user.authenticated = no


UserService.$inject = ['$http', '$q', '$cordovaFacebook', '$window', 'kfUri', '$rootScope', '$timeout']
angular.module('kf.shared').service 'userService', UserService
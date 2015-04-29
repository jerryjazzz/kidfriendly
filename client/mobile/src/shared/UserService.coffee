'use strict'
class UserService
  constructor: ($http, @$q, @$cordovaFacebook, @$window, @$rootScope)->
    @user = angular.fromJson @$window.localStorage.getItem("user")
    if not @user? then @user = {authenticated:no}

  loginOrSignUp: ->
    defer = @$q.defer()
    @$cordovaFacebook.login (["public_profile", "email", "user_friends"])
    .then (success) =>
      @user.firstName = 'Joe'
      @user.lastName = 'Rozek'
      @user.accessToken = success.authResponse.accessToken
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



UserService.$inject = ['$http', '$q', '$cordovaFacebook', '$window', '$rootScope']
angular.module('kf.shared').service 'userService', UserService
'use strict'
class UserService
  constructor: (@$http, @$q, @$cordovaFacebook, @$window, @kfUri, @$rootScope, @$timeout)->
    @user = @_userFromLocalStorage()

  httpGet: (path) ->
    url = "http://#{@kfUri}" + path
    @$http.get(url, headers: {Accept: 'application/json'})

  _userFromLocalStorage: ->
    usr = angular.fromJson @$window.localStorage.getItem("user")
    if usr?
      @user = new User(usr)
    else
      @user = new User({})

  getUser: ->
    defer = @$q.defer()
    if not @user? then @$timeout =>
      defer.resolve(@user)
    if @user.isAuthenticated()
      @$timeout => defer.resolve(@user)
    else if @user.accessToken?
      @getUserForToken(@user.accessToken).then (user) =>
        defer.resolve
    else @$timeout => defer.resolve(@user)

    defer.promise

  getUserForToken: (token) ->
    defer = @$q.defer()
    @httpGet("/api/user/me?facebook_token=#{token}").success (kfUser) =>
      @user.userId = kfUser.user_id
      @user.email = kfUser.email
      @$window.localStorage.setItem('user', angular.toJson(@user))
      @$rootScope.$broadcast '$authenticationSuccess', @user
      defer.resolve @user
    .error (error) =>
      console.log 'error', error
      defer.reject error
    defer.promise

  loginOrSignUp: ->
    defer = @$q.defer()
    @$cordovaFacebook.login (["public_profile", "email", "user_friends"])
    .then (success) =>
      @user.accessToken = success.authResponse.accessToken
      @user.setExpiryDate(success.authResponse.expiresIn)
      @getUserForToken(success.authResponse.accessToken).then (kfUser) =>
        defer.resolve @user
    , (error) =>
      defer.reject(error)
    defer.promise

  logout: ->
    @$window.localStorage.removeItem('user')
    @user.email = undefined
    @user.accessToken = undefined
    @user.userId = undefined
    @user.expiryDate = undefined

  class User
    constructor:({@email, @userId, @accessToken, @expiryDate})->
      @expiryDate = new Date(@expiryDate)

    isAuthenticated: -> @userId? and @accessToken? and @expiryDate?.getTime() > Date.now()

    setExpiryDate:(seconds) ->
      now = Date.now() + seconds * 1000
      @expiryDate = new Date(now)

UserService.$inject = ['$http', '$q', '$cordovaFacebook', '$window', 'kfUri', '$rootScope', '$timeout']
angular.module('kf.shared').service 'userService', UserService
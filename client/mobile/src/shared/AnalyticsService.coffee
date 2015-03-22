'use strict'
class AnalyticsService
  constructor: (@$window, @$ionicPlatform, @$rootScope) ->

  initAndTrackPages:() ->
    @$ionicPlatform.ready =>
      @al = @$window.analytics
      @al = @_createMockAnalytics() unless @al?
      id =  @_getAnalyticsId()

      if id?
        @al?.startTrackerWithId(id)
        @al?.debugMode()
        @$rootScope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) =>
          @al?.trackView(toState.name)

  setUser:(userId) ->
    @al?.setUserId(userId)

  trackEvent: (category, action, label, value) ->
    @al?.trackEvent(category, action, label, value)

  _getAnalyticsId:->
    return 'UA-54877459-2' if ionic?.Platform.isIOS()
    return 'UA-54877459-3' if ionic?.Platform.isAndroid()


  _createMockAnalytics:->
    analytics =
      startTrackerWithId: (id) ->
        console.log 'startTrackerWithId: ', id
      debugMode: ->
        console.log 'debugMode'
      trackView: (id) ->
        console.log 'trackView: ', id
      setUserId: (id) ->
        console.log 'setUserId: ', id
      trackEvent: (category, action, label, value) ->
        console.log 'trackEvent: ', category, action, label, value
    analytics

AnalyticsService.$inject = ['$window', '$ionicPlatform', '$rootScope']
angular.module('kf.shared').service 'analyticsService', AnalyticsService
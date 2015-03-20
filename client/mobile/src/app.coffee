'use strict'
# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js
angular.module('Mobile', ['ionic', 'config', 'kf.shared', 'UserApp', 'ngCordova', 'ngTouch', 'angular-carousel', 'uiGmapgoogle-maps'])
.run ($ionicPlatform, user, $state, $ionicHistory) ->
  attemptedRoute = undefined
  #userApp user object
  user.init
    appId: '***REMOVED***'
    heartbeatInterval: 600000

  user.onAuthenticationRequired (route, stateParams) =>
    attemptedRoute =
      route: route
      params: stateParams
    $state.go 'login'


  user.onAuthenticationSuccess =>
    if attemptedRoute?
      $ionicHistory.currentView($ionicHistory.backView());
      $state.transitionTo  attemptedRoute.route.name, attemptedRoute.params
      attemptedRoute = undefined

  $ionicPlatform.ready ->
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if(window.cordova && window.cordova.plugins.Keyboard)
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if(window.StatusBar)
      # org.apache.cordova.statusbar required
      StatusBar.styleDefault()

.config ($stateProvider, $urlRouterProvider, resolvers, uiGmapGoogleMapApiProvider) ->
  uiGmapGoogleMapApiProvider.configure
    key: 'AIzaSyC0wntPebMoKnIwbpa82NzLPbwEIlvZvlM'
    v: '3.17'
    libraries: 'weather,geometry,visualization'

  # Ionic uses AngularUI Router which uses the concept of states
  # Learn more here: https:#github.com/angular-ui/ui-router
  # Set up the various states which the app can be in.
  # Each state's controller can be found in controllers.js

  $stateProvider

    # setup an abstract state for the tabs directive
  .state 'search',
    url: '/search/:keyword'
    templateUrl: 'templates/search-results.html'
    controller: 'SearchCtrl'
    resolve:
      results: resolvers.results
    data:
      public: true
    public:true

  .state 'login',
    url: '/login'
    templateUrl: 'templates/login.html'
    data:
      login: true

  .state 'signup',
    url: '/signup'
    templateUrl: 'templates/signup.html'
    data:
      public: true

  .state 'start',
    url: '/start'
    templateUrl: 'templates/start.html'
    controller: 'StartCtrl'
    resolve:
      position: resolvers.position
    data:
      public: true
    public: true

  .state 'review',
    url: '/review/:placeId'
    templateUrl: 'templates/review.html'
    controller:'ReviewCtrl'

  .state 'details',
    url:'/details/:placeId'
    templateUrl: 'templates/details.html'
    resolve:
      place: resolvers.place
    controller:'DetailsCtrl'
    data:
      public: true
    public: true

  .state 'thankyou',
    url:'/thankyou'
    templateUrl: 'templates/review-thankyou.html'
    controller:'DetailsCtrl'

  $urlRouterProvider.otherwise('/start')
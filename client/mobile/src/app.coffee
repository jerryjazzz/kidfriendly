'use strict'
# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js
angular.module('Mobile', ['ionic', 'config', 'kf.shared', 'UserApp'])
.run ($ionicPlatform, user) ->
  #userApp user object
  user.init({ appId: '***REMOVED***' })

  $ionicPlatform.ready ->
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if(window.cordova && window.cordova.plugins.Keyboard)
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if(window.StatusBar)
      # org.apache.cordova.statusbar required
      StatusBar.styleDefault()

.config ($stateProvider, $urlRouterProvider) ->
  # Ionic uses AngularUI Router which uses the concept of states
  # Learn more here: https:#github.com/angular-ui/ui-router
  # Set up the various states which the app can be in.
  # Each state's controller can be found in controllers.js
  $stateProvider

    # setup an abstract state for the tabs directive
  .state 'search',
    url: '/search'
    templateUrl: 'templates/search.html'
    controller: 'SearchCtrl'
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
    controller: 'SearchCtrl'
    data:
      public: true

  .state 'review',
    url: '/review/:placeId'
    templateUrl: 'templates/review.html'
    controller:'ReviewCtrl'

  .state 'review2',
    url: '/review2/:placeId'
    templateUrl: 'templates/review-service.html'
    controller:'ReviewCtrl'

  .state 'review3',
    url: '/review3/:placeId'
    templateUrl: 'templates/review-atmosphere.html'
    controller:'ReviewCtrl'

  .state 'results',
    url:'/results'
    templateUrl: 'templates/search-results.html'
    controller:'ResultsCtrl'
    data:
      public: true

  .state 'details',
    url:'/details/:placeId'
    templateUrl: 'templates/details.html'
    controller:'DetailsCtrl'
    data:
      public: true

  .state 'thankyou',
    url:'/thankyou'
    templateUrl: 'templates/review-thankyou.html'
    controller:'DetailsCtrl'

  $urlRouterProvider.otherwise('/start')


'use strict'
angular
  .module('web', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/email.html'
        controller: 'MainCtrl'
      .when '/survey',
        templateUrl: 'views/survey.html'
      .when '/thankyou',
        templateUrl: 'views/thankyou.html'
      .otherwise
        redirectTo: '/'


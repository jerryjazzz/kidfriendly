'use strict'
angular
  .module('web', [
    'ngRoute'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/email.html'
      .when '/survey',
        templateUrl: 'views/survey.html'
      .when '/thankyou',
        templateUrl: 'views/thankyou.html'
      .otherwise
        redirectTo: '/'

  .run ['$rootScope', '$location', 'gaService', ($rootScope, $location, gaService) ->
    $rootScope.$on '$locationChangeStart', ()->
      gaService('send', 'pageview', {page:$location.path()})
    ]


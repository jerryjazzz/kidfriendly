'use strict'
FacebookButtonDirective = ->
  restrict:"E"
  controller: ['$scope', 'userService', ($scope, userService)->
    $scope.login = ->
      userService.loginOrSignUp().then (user) =>
        #might might need a callback for redirection?
        console.log 'logged in!!!', user
        $scope.user = user
    userService.getUser().then (user) => $scope.user = user

  ]
  template:"""
  <button class="button button-treatment button-block button-positive" ng-click="login()"
          ng-hide='user.isAuthenticated()'>
    <i class="icon-smaller ion-social-facebook"></i>
      Sign up with Facebook
  </button>
  """

angular.module('Mobile').directive 'kfFacebookButton', FacebookButtonDirective
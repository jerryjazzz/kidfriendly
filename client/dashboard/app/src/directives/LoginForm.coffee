
angular.module('dashboardApp').directive 'loginForm', ->
  templateUrl: 'views/login-form.html'
  controller: ($scope) ->
    $scope.submit = ->
      console.log('logging in: ', {@username, @password})
      UserApp.User.login {login: @username, password: @password}, (error, results) ->
        console.log('login finished! ', error, results)

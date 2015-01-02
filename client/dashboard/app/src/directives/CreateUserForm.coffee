
angular.module('dashboardApp').directive 'createUserForm', ->
  templateUrl: 'views/create-user-form.html'
  controller: ($scope) ->
    $scope.submit = ->
      console.log('saving new user: ', {@username, @password})
      UserApp.User.save {login: @username, password: @password}, (error, results) ->
        console.log('new user created! ', error, results)

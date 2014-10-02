'use strict'
class EmailMeCtrl
  constructor:(@$scope, @$http, @$location, @splashPageService)->

  _submitEmail: ->
    @$http.post('http://www.kidfriendly.biz/submit/email', {email:@$scope.email})
    .success (data) =>
      @splashPageService.id = data.id
      @$location.path '/survey'
    .error (data) ->
      console.log 'error', data

  sendEmail: () ->
    console.log 'email', @$scope.email
    @_submitEmail() if @$scope.email?

EmailMeCtrl.$inject = ['$scope', '$http', '$location', 'splashPageService']
angular.module('web').controller 'EmailMeCtrl', EmailMeCtrl
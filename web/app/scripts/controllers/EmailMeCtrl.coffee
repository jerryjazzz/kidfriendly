'use strict'
class EmailMeCtrl
  constructor:(@$scope, @$http, @$location)->

  _submitEmail: ->
    @$http.post('http://www.kidfriendly.biz/submit/email', {email:@$scope.email})
    .success (data) =>
      @$location.path '/survey'
    .error (data) ->
      console.log 'error', data

  sendEmail: () ->
    console.log 'email', @$scope.email
    @_submitEmail() if @$scope.email?

EmailMeCtrl.$inject = ['$scope', '$http', '$location']
angular.module('web').controller 'EmailMeCtrl', EmailMeCtrl
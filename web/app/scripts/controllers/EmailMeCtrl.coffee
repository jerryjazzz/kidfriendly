class EmailMeCtrl
  constructor:(@$scope, @$http)->

  _submitEmail: ->
    @$http.post('http://www.kidfriendly.biz/submit/email', {email:@$scope.email})
    .success (data) ->
      console.log 'success', data
    .error (data) ->
      console.log 'erro', data

  sendEmail: () ->
    console.log 'email', @$scope.email
    @_submitEmail() if @$scope.email?

EmailMeCtrl.$inject = ['$scope', '$http']
angular.module('web').controller 'EmailMeCtrl', EmailMeCtrl
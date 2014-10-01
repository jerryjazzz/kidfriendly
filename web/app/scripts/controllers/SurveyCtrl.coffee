'use strict'
class SurveyCtrl
  constructor:(@$scope, @$http, @$location)->

  submitAnswer: ->
    @$location.path '/thankyou'
#    @$http.post('http://www.kidfriendly.biz/submit/email', {email:@$scope.email})
#    .success (data) =>
#      @$location.path '/survey'
#    .error (data) ->
#      console.log 'error', data

SurveyCtrl.$inject = ['$scope', '$http', '$location']
angular.module('web').controller 'SurveyCtrl', SurveyCtrl
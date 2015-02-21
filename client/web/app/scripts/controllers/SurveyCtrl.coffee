'use strict'
class SurveyCtrl
  constructor:(@$scope, @$http, @$location, @splashPageService)->
    @$scope.answered = yes
  submitAnswer: ->
    payload =
      signup_id:@splashPageService.id
      survey_version: 1
      answer:@$scope.surveyAnswer

    @$http.post('/api/submit/survey_answer', payload)
    .success (data) =>
      @$location.path '/thankyou'
      console.log 'success', data
      @$location.path '/thankyou'
    .error (data) =>
      @$location.path '/thankyou'
      console.log 'error', data

SurveyCtrl.$inject = ['$scope', '$http', '$location', 'splashPageService']
angular.module('web').controller 'SurveyCtrl', SurveyCtrl

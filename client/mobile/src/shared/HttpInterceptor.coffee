httpInterceptor = ($q, $injector) ->
  MAX_FAILURES_BEFORE_REJECTION =1
  DEFAULT_TIMEOUT = 10000

  request:(config) ->
    if config? then config.timeout = DEFAULT_TIMEOUT
    config || $q.when(config)

  responseError:(rejection) ->
    if rejection.config.numFailures?
      rejection.config.numFailures++
    else
      rejection.config.numFailures = 1

    if(rejection.config.numFailures >= MAX_FAILURES_BEFORE_REJECTION)
      console.log 'rejection', rejection
      window.analytics.trackException("status: #{rejection.status} ::: data: #{rejection.data}" , false)
      return $q.reject(rejection)
    else
      $http = $injector.get('$http')
      $http(rejection.config)

httpInterceptor.$inject = ['$q', '$injector']

angular.module('kf.shared').factory 'myHttpInterceptor', httpInterceptor
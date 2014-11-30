
class UserAppValidateToken
  constructor: (@app) ->

  start: (token) ->
    #@cacheKey = 'UserAppValidateToken:'+token
    #if (cached = @app.cache.get(@cacheKey))
    #app.request("https://api.userapp.io/v1/token.get?app_id=#{UserAppUtil.appId}&token_id=#{token}")
    # TODO

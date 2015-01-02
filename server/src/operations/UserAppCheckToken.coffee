
class UserAppCheckToken
  constructor: (@app) ->

  start: (token) ->
    @cacheKey = 'UserAppCheckToken:'+token
    if (cached = @app.cache.get(@cacheKey))
      return cached

    app.request("https://api.userapp.io/v1/token.get?app_id=#{UserAppUtil.appId}&token_id=#{token}")
    .then (result) ->
      @app.cache.set(cacheKey, result)
      return result

    .catch (err) =>
      @app.log("userapp replied with error: ", err)
      return null

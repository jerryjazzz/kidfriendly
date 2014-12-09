
class SearchEndpoint
  constructor: (@app) ->
    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/nearby', wrap (req) =>
      search = new GoogleSearch(@app)
      search.start(nearby: req.query)

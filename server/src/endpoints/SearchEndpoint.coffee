
class SearchEndpoint
  constructor: (@app) ->

    wrap = (f) -> ExpressUtil.wrap({}, f)

    @endpoint = require('express')()

    @endpoint.get '/latlong/:latlong', wrap (req) =>

    @endpoint.get '/zipcode/:zipcode', wrap (req) =>

  @create: (app) ->
    (new SearchEndpoint(app)).endpoint

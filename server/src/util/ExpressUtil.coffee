
Promise = require('bluebird')

class ExpressUtil
  constructor: ->
    @htmlPresentation = depend('HtmlPresentation')

  wrappedGet: (router, path, arg1, arg2) =>
    router.get(path, @wrapRequestHandler(arg1, arg2))

  wrappedPost: (router, path, arg1, arg2) =>
    router.post(path, @wrapRequestHandler(arg1, arg2))
  
  wrapRequestHandler: (arg1, arg2) ->
    if arg2?
      options = arg1
      callback = arg2
    else
      options = {}
      callback = arg1

    handler = (req, res) =>
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (result) =>
          @writeResponse(req, res, options, result)

        .catch (err) ->
          statusCode = err?.statusCode ? 500
          res.set('Content-Type', 'text/plain')
          res.status(statusCode).send(err.stack ? err)

    return handler

  writeResponse: (req, res, options, result) ->
    statusCode = result?.statusCode ? 200

    if result?.contentType?
      # Result has custom content-type, don't mess with it.
      res.set('Content-Type', result.contentType)
      res.status(statusCode).send(result.content)
      return

    # Returning a plain JSON value

    if req.accepts('html')
      # Wrap json result in a nice html presentation
      res.set('Content-Type', 'text/html')
      html = @htmlPresentation.render(options.type, result)
      res.status(statusCode).send(html)
      return

    res.set('Content-Type', 'application/json')
    json = JSON.stringify(result, null, '\t')
    res.status(statusCode).send(json)

provide('ExpressUtil', ExpressUtil)
provide('ExpressGet', -> depend('ExpressUtil').wrappedGet)
provide('ExpressPost', -> depend('ExpressUtil').wrappedPost)

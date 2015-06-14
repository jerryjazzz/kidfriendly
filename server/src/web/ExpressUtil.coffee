
Promise = require('bluebird')
React = require('react')

class ExpressUtil
  constructor: ->

  wrapRequestHandler: (callback) ->
    handler = (req, res) =>
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (data) =>
          @renderResponse(req, res, data)

        .catch (err) ->
          if typeof err == 'string'
            err = {error: err}
          err.statusCode ?= 500
          res.set('Content-Type', 'text/plain')
          res.status(err.statusCode).send(err.stack ? err)

    return handler

  routerFromObject: (obj) ->
    router = require('express')()
    for path, handler of obj
      wrappedHandler = @wrapRequestHandler(handler)
      switch
        when path.indexOf('post ') == 0
          router.post(path.slice(5), wrappedHandler)
        when path == 'use'
          router.use(handler)
        when path.indexOf('use ') == 0
          router.use(path.slice(4), handler)
        else
          router.get(path, wrappedHandler)
    return router

  renderResponse: (req, res, data) ->
    statusCode = data?.statusCode ? 200

    if not req.accepts('html')
      # Plain JSON response
      res.set('Content-Type', 'application/json')
      json = JSON.stringify(data, null, '\t')
      res.status(statusCode).send(json)
      return

    # Find view name, possibly from the data itself.
    # Default view is jsonDump (used when a browser loads a plain JSON endpoint)
    viewName = data?.view ? 'view/jsonDump'

    view = depend(viewName)(data)

    if view.content? and view.contentType?
      # Custom content type
      res.set('Content-Type', view.contentType)
      res.status(statusCode).send(view.content)
      return

    if (not view.body?) or (not view.title?)
      throw new Error("View needs to return {body,title} (for now)")

    @renderBootstrapHTML(req, res, statusCode, view)

  renderBootstrapHTML: (req, res, statusCode, view) ->
    html = """
    <html>
      <head>
        <title>#{view.title}</title>
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">
          <script src="/js/jquery.min.js"></script>
      </head>
      #{React.renderToStaticMarkup(view.body)}
    </html>
    """

    res.set('Content-Type', 'text/html')
    res.status(statusCode).send(html)
    return

provide.class(ExpressUtil)


Promise = require('bluebird')
React = require('react')

class ExpressUtil
  constructor: ->

  wrappedGet: (router, path, arg1, arg2) =>
    router.get(path, @wrapRequestHandler(arg1, arg2))

  wrappedPost: (router, path, arg1, arg2) =>
    router.post(path, @wrapRequestHandler(arg1, arg2))
  
  wrapRequestHandler: (callback) ->
    handler = (req, res) =>
      callbackResult = callback(req)
      Promise.resolve(callbackResult)
        .then (data) =>
          @renderResponse(req, res, data)

        .catch (err) ->
          statusCode = err?.statusCode ? 500
          res.set('Content-Type', 'text/plain')
          res.status(statusCode).send(err.stack ? err)

    return handler

  renderResponse: (req, res, data) ->
    statusCode = data?.statusCode ? 200

    if data?.contentType?
      # Result has custom content-type, don't mess with it.
      res.set('Content-Type', data.contentType)
      res.status(statusCode).send(data.content)
      return

    if not req.accepts('html')
      # Plain JSON response
      res.set('Content-Type', 'application/json')
      json = JSON.stringify(data, null, '\t')
      res.status(statusCode).send(json)
      return

    # Find view name, possibly from the data itself.
    # Default view is jsonDump (used when a browser loads a plain JSON endpoint)
    console.log('data = ', data)
    viewName = data.presentation ? 'view/jsonDump'
    console.log('viewName = ', viewName)

    view = depend(viewName)(data)
    if (not view.body?) or (not view.title?)
      throw new Error("View needs to return {body,title} (for now)")

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

provide('ExpressUtil', ExpressUtil)
provide('ExpressGet', -> depend('ExpressUtil').wrappedGet)
provide('ExpressPost', -> depend('ExpressUtil').wrappedPost)

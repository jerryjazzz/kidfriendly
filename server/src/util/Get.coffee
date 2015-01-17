
# Function for setting up a wrapped Express handler.

# 'handler' is a function (req) -> (response value, maybe a Promise)
Get = (router, path, options, handler) ->
  router.get path, (req, res) ->
    Promise.resolve(handler(req))
      .then (result) ->
        statusCode = result.statusCode ? 200
        res.status(statusCode).json(result)
      .catch (err) ->
        statusCode = err.statusCode ? 500
        res.status(statusCode).send(JSON.stringify(err.stack ? err))


# Function for setting up a wrapped Express handler.

# 'handler' is a function (req) -> (response value, maybe a Promise)
Get = (router, path, options, handler) ->
  router.get path, ExpressUtil.wrap({}, handler)

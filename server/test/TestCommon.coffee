
{depend, depend_optional, provide} = require('kfly_server')

class FakeApp
  constructor: ->

testDepend = (name) ->
  # make sure a fake App is installed
  if not depend_optional('App')?
    provide('App', -> new FakeApp())

  return depend(name)

exports.depend = testDepend

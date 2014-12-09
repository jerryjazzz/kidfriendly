
{EventEmitter} = require('events')

class Task extends EventEmitter
  constructor: (values) ->
    for key,value of values
      this[key] = value

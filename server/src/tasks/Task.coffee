
EventEmitter = require('events').EventEmitter

class Task extends EventEmitter
  constructor: ({options}) ->
    for key,value of options
      this[key] = value

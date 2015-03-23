
fs = require('fs')

class Log
  constructor: (app, @name) ->
    if not name?
      throw new Error("log name is required")

    @filename = "data/log/#{name}"
    @fileStream = fs.createWriteStream(@filename, {flags: 'a'})
    @fileStream.on 'error', (err) =>
      console.log("error: File stream error for #{@filename}: ", err)

  write: (obj, encoding='utf8') ->
    if typeof obj is 'string'
      str = obj.trim()
    else
      str = JSON.stringify(obj)

    @fileStream.write(str+"\n", encoding)

provide('Log', -> Log)

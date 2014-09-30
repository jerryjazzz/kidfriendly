
fs = require('fs')

class Log
  constructor: (config, @name) ->
    @filename = "data/log/#{name}.json"
    @fileStream = fs.createWriteStream(@filename, {flags: 'a'})
    @fileStream.on 'error', (err) =>
      console.log("error: File stream error for #{@filename}: ", err)

  write: (obj) ->
    jsonString = JSON.stringify(obj) + "\n"
    @fileStream.write(jsonString, 'utf8')

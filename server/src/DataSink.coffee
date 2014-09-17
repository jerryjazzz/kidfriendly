
fs = require('fs')

class DataSink
  constructor: (config, @name) ->
    @filename = "data/log/#{name}.json"

  send: (obj) ->
    jsonString = JSON.stringify(obj) + "\n"

    fs.appendFile @filename, jsonString, 'utf8', (err) =>
      if err?
        console.log("error: Failed to write to #{@filename}: ", err)

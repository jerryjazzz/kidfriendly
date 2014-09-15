
class Main
  constructor: ->
    @app = require('express')()
    handlebars = require('express-handlebars')

    @app.use(require('express-domain-middleware'))
    @app.use(require('morgan')('[:date] :method :url :status :res[content-length] - :response-time ms'))

    staticFileMap =
      '/js/bootstrap.js': '../web/js/bootstrap.min.js'
      '/css/bootstrap.css': '../web/css/bootstrap.min.css'
      '/css/bootstrap-theme.css': '../web/css/bootstrap-theme.min.css'
      '/fonts/glyphicons-halflings-regular.ttf': '../web/fonts/glyphicons-halflings-regular.ttf'
      '/': '../web/html/splash.html'
      '/assets/pasta_kid.jpg': '../web/assets/pasta_kid.jpg'
      '/assets/kids_meal_kids.jpg': '../web/assets/kids_meal_kids.jpg'

    for path, filename of staticFileMap
      filename = require('path').resolve(filename)
      do (path, filename) =>
        @app.get path, (req,res) =>
          res.sendFile(filename)

  run: ->
    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

startup = ->
  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  process.chdir(__dirname + '/..')
  
  main = new Main()
  main.run()

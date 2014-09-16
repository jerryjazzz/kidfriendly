
mysql = require('mysql')
path = require('path')

class Main
  constructor: ->
    express = require('express')
    @app = express()

    # Middleware
    handlebars = require('express-handlebars')
    @app.use(require('express-domain-middleware'))
    @app.use(require('morgan')('[:date] :method :url :status :res[content-length] - :response-time ms'))

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @app.get("/", staticFile('web/dist/index.html'))
    @app.get("/index.html", redirect('/'))
    @app.use(staticDir('web/dist'))

    @db = mysql.createConnection
      host: 'localhost'
      user: 'web'
      database: 'kidfriendly'

    @db.connect()

    @emailSignup = new EmailSignup(this)

  run: ->
    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

startup = ->
  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  console.log('changing current dir to: ' + dir)
  process.chdir(dir)
  
  main = new Main()
  main.run()

startup()

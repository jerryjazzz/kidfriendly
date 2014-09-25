
path = require('path')

class Server

  constructor: (@config) ->
    
    express = require('express')
    @app = express()


    @app.use (req, res, next) ->
      req.get_ip = ->
        this.headers['x-forwarded-for'] or this.connection.remoteAddress
      next()

    # Middleware
    @app.use(require('express-domain-middleware'))
    @app.use(require('cookie-parser')())
    @app.use(require('body-parser').json())

    @app.use(require('morgan')('[:date] :method :url :status :res[content-length] - :response-time ms'))

    @app.use(@cors)

    # Routes
    staticFile = (filename) -> ((req,res) -> res.sendFile(path.resolve(filename)))
    staticDir = (dir) -> express.static(path.resolve(dir))
    redirect = (to) -> ((req,res) -> res.redirect(301, to))

    @app.get("/", staticFile('web/dist/index.html'))
    @app.get("/index.html", redirect('/'))
    @app.use(staticDir('web/dist'))

    mysql = require('mysql')
    @db = mysql.createConnection
      host: 'localhost'
      user: 'web'
      database: 'kidfriendly'

    @db.connect (err, conn) ->
      if err?
        console.log("[error] from db.connect: ", err)
      else
        console.log("Mysql connected")

    @handlers =
      emailSignup: new EmailSignup(this)

    @logs =
      emailSignup: new Log(config, 'email_signup')

  cors: (req, res, next) =>
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type')
    res.set('Access-Control-Allow-Origin', '*')
    next()
    #res.set('Access-Control-Expose-Headers', ...)

  run: ->
    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

startup = ->
  # Change directory to top-level, one above the 'server' dir. (such as /kfly)
  dir = path.resolve(path.join(__dirname, '../..'))

  console.log('Changing current dir to: ' + dir)
  process.chdir(dir)

  config = require('./../config')
  
  main = new Server(config)
  main.run()

startup()

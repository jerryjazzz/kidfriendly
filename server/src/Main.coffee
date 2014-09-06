
class Main
  constructor: ->
    @app = require('express')()
    handlebars = require('express-handlebars')

    @app.use(require('express-domain-middleware'))
    @app.use(require('morgan')('[:date] :method :url :status :res[content-length] - :response-time ms'))

    @app.get '/', (req, res) =>
      res.send(200, "Success")

  run: ->
    port = 3000
    console.log("Launching server on port #{port}")
    @app.listen(port)

main = new Main()
main.run()

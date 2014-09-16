
class EmailSignup
  constructor: (@server) ->

    @server.app.post "/submit/email", (req, res) =>

      data = {id: 1, email: 'theemail', json: '', created_at: Date.now()}

      @server.db.query 'INSERT INTO user SET ?', data, (err, result) =>
        if err?
          console.log('err = ', err)
        if result?
          console.log('result = ', err)

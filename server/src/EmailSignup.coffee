
class EmailSignup
  constructor: (@server) ->

    @server.app.post "/submit/email", (req, res) =>

      if not req.body.email?
        res.status(400).send("'email' field is required")
        return
      if not req.body.zipcode?
        res.status(400).send("'zipcode' field is required")
        return

      data =
        email: req.body.email
        zipcode: req.body.zipcode
        ip: req.get_ip()
        created_at: DateUtil.timestamp()

      @server.sinks.emailSignup.send(data)

      res.status(200).end()

      @server.db.query 'INSERT INTO email_signup SET ?', data, (err, result) =>
        if err?
          console.log("email_signup mysql error: ", err)


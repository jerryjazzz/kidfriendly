
class EmailSignup
  constructor: (@server) ->

    @server.app.post "/submit/email", (req, res) =>

      if not req.body.email?
        res.status(400).send("'email' field is required")
        return

      data =
        email: req.body.email
        created_at: DateUtil.timestamp()
        ip: req.get_ip()
        source_ver: @server.sourceVersion

      @server.logs.emailSignup.send(data)

      Database.writeRow(@server, 'email_signup', data, {generateId: true})
        .then (write) ->
          if write.error?
            res.status(400).send(write.error)
          else
            res.status(200).send(id: write.id)


class SubmitEndpoint
  constructor: (@server) ->

    app = @server.app

    withRequiredFields = (fields, next) ->
      (req, res) ->
        for field in fields
          if not req.body[field]?
            res.status(400).send("'#{field}' field is required")
            return

        next(req, res)

    app.post '/submit/email', withRequiredFields ['email'], (req, res) =>

      data =
        email: req.body.email
        created_at: DateUtil.timestamp()
        ip: req.get_ip()
        source_ver: @server.sourceVersion

      @server.logs.emailSignup.write(data)

      Database.writeRow(@server, 'email_signup', data, {generateId: true})
        .then (write) ->
          if write.error?
            res.status(400).send(msg: 'SQL error', caused_by: write.error)
          else
            res.status(200).send(id: write.id)

    app.post '/submit/survey_answer', withRequiredFields ['signup_id', 'survey_version', 'answer'], (req, res) =>

      row =
        signup_id: parseInt(req.body.signup_id)
        survey_version: req.body.survey_version
        answer: req.body.answer
        created_at: DateUtil.timestamp()
        source_ver: @server.sourceVersion

      @server.logs.surveyAnswer.write(row)

      Database.writeRow(@server, 'survey_answer', row)
        .then (write) ->
          if write.error?
            res.status(400).send(msg: 'SQL error', caused_by: write.error)
            return
          res.status(200).end()
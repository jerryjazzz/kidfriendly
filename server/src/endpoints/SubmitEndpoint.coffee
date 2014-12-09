mcapi = require('mailchimp-api')

class SubmitEndpoint
  constructor: (@app) ->
    @endpoint = require('express')()
    @emailSignupLog = new Log(@app, 'email_signup.json')
    @surveyAnswerLog = new Log(@app, 'survey_answer.json')
    mc = new mcapi.Mailchimp('7c0352fbb770ec2a76b0d631df95d473-us9')

    withRequiredFields = (fields, next) ->
      (req, res) ->
        for field in fields
          if not req.body[field]?
            res.status(400).send("'#{field}' field is required")
            return

        next(req, res)

    @endpoint.post '/email', withRequiredFields ['email'], (req, res) =>

      data =
        email: req.body.email
        created_at: DateUtil.timestamp()
        ip: req.get_ip()
        source_ver: @app.sourceVersion

      @emailSignupLog.write(data)
      mc.lists.subscribe({id: '60e31526fb', email:{email:req.body.email}},
      (data) ->
        #do nothing
        (error) =>
          if error.error?
            @app.log("MailChimp Error: #{error.error}")
          else
            @app.log("MailChimp Error: unspecified error")
      )

      Database.writeRow(@app, 'email_signup', data, {generateId: true})
        .then (write) ->
          if write.error?
            res.status(400).send(msg: 'SQL error', caused_by: write.error)
          else
            res.status(200).send(id: write.id)

    @endpoint.post '/survey_answer', withRequiredFields ['signup_id', 'survey_version', 'answer'], (req, res) =>

      row =
        signup_id: parseInt(req.body.signup_id)
        survey_version: req.body.survey_version
        answer: req.body.answer
        created_at: DateUtil.timestamp()
        source_ver: @app.sourceVersion

      @surveyAnswerLog.write(row)

      Database.writeRow(@app, 'survey_answer', row)
        .then (write) =>
          if write.error?
            @app.log(msg: 'SQL error', caused_by: write.error, row: row)
            res.status(400).send(msg: 'SQL error', caused_by: write.error)
            return
          res.status(200).end()

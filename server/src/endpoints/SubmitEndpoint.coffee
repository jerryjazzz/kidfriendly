mcapi = require('mailchimp-api')

class SubmitEndpoint
  constructor: ->
    @app = depend('App')
    @route = require('express')()
    Log = depend('Log')
    @emailSignupLog = new Log(@app, 'email_signup.json')
    @surveyAnswerLog = new Log(@app, 'survey_answer.json')
    mc = new mcapi.Mailchimp('7c0352fbb770ec2a76b0d631df95d473-us9')
    get = depend('ExpressGet')
    post = depend('ExpressPost')

    post @route, '/email', (req) =>

      data =
        email: req.body.email
        created_at: timestamp()
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

      @app.insert('email_signup', data)
      .then ->
        data.id

    post @route, '/survey_answer', (req) =>

      row =
        signup_id: req.body.signup_id
        body: JSON.stringify
          survey_version: req.body.survey_version
          answer: req.body.answer
        created_at: timestamp()
        source_ver: @app.sourceVersion

      @surveyAnswerLog.write(row)

      @app.insert('survey_answer', row)

provide('SubmitEndpoint', SubmitEndpoint)

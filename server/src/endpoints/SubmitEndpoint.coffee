mcapi = require('mailchimp-api')

provide 'endpoint/api/submit', ->
  App = depend('App')
  mc = new mcapi.Mailchimp('7c0352fbb770ec2a76b0d631df95d473-us9')

  'post /email': (req) ->
    data =
      email: req.body.email
      created_at: timestamp()
      ip: req.get_ip()
      source_ver: App.sourceVersion

    mc.lists.subscribe({id: '60e31526fb', email:{email:req.body.email}},
    (data) ->
      #do nothing
      (error) =>
        if error.error?
          console.log("MailChimp Error: #{error.error}")
        else
          console.log("MailChimp Error: unspecified error")
    )

    App.insert('email_signup', data)
    .then ->
      data.id

  'post /survey_answer': (req) ->

    row =
      signup_id: req.body.signup_id
      body: JSON.stringify
        survey_version: req.body.survey_version
        answer: req.body.answer
      created_at: timestamp()
      source_ver: App.sourceVersion

    App.insert('survey_answer', row)

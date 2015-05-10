
React = require('react')
{html,body,div,span,table,td,tr,h1,h3,code,a,form,input,script} = React.DOM

Script = (f) ->
  # Super hack, stringify a function for client. Proper thing to do would be
  # to write real React components and then load them on client.
  str = "(#{f.toString()})()"
  script {dangerouslySetInnerHTML:__html:str}

provide 'view/admin/home', -> (data) ->
  title: 'Kidfriendly Admin'
  body: body {},
    (h1 {}, "/admin"),

    a {href:'/admin/logout'}, "Logout"

    h3 {}, 'User info'

    div {}, "Your user data: "+JSON.stringify(data.user)

    div {}, "Your Facebook token: "+data.facebookToken

    h3 {}, 'Tools'

    div {},
      "Get excel dump for zipcode: ",
      input {id: 'get_excel_dump_input'}

    Script ->
      $('#get_excel_dump_input').keydown (e) ->
        if e.keyCode == 13
          zipcode = $('#get_excel_dump_input')[0].value
          window.location = '/api/search/exceldump?zipcode=' + zipcode

    h3 {}, 'Browse'

    div {}, a {href:'/api/place/any'}, '/place/any'
    div {}, a {href:"/api/user/me?facebook_token=#{data.facebookToken}"}, '/user/me'
    div {}, a {href:"/api/user/me/reviews?facebook_token=#{data.facebookToken}"}, '/user/me/reviews'

provide 'view/admin/login-required', -> (data) ->
  title: 'Error'
  body: body {},
    (h3 {}, "Login Required"),
    (a {href:'/admin/auth/facebook'}, "Login with Facebook")

provide 'view/admin/email-not-on-whitelist', -> (data) ->
  title: 'Error'
  body: body {},
    h3 {}, "Login error"
    div {}, "Email not on whitelist: #{data.email}"
    a {href:'/admin/logout'}, "Logout"

provide 'view/admin/logged-out', -> (data) ->
  title: 'Logged out'
  body: body {},
    h3 {}, "Logged out"
    (a {href:'/admin/auth/facebook'}, "Login with Facebook")


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

    (a {href:'/admin/auth/facebook'}, "Facebook login"),

    div {}, "User data: "+JSON.stringify(data.user)

    div {},
      "Get excel dump for zipcode: ",
      input {id: 'get_excel_dump_input'}

    Script ->
      $('#get_excel_dump_input').keydown (e) ->
        if e.keyCode == 13
          zipcode = $('#get_excel_dump_input')[0].value
          window.location = '/api/search/exceldump?zipcode=' + zipcode



React = require('react')
{html,body,div,table,td,tr,h3,code,a,form} = React.DOM

JsonTable = (data) ->
  rows = for k,v of data
    if ObjectUtil.isObject(v)
      v = JSON.stringify(v)
    tr {key:k}, (td {}, k), (td {}, v)
  table {className: "table table-striped"}, rows

getTitle = (data) ->
  data.name ? ''

getLinks = (data) ->
  if data.type == 'Place'
    return {
      'Details': "/api/place/#{data.place_id}/details"
      'Reviews': "/api/place/#{data.place_id}/details/reviews"
      'Factual source': 'http://factual.com/'+data.factual_id
    }
  {}

LinkSection = (data) ->
  links = getLinks(data)

  items = for name, url of links
    a {key:name, className: 'btn btn-default', href: url}, name

  if items.length == 0
    return div()

  div {},
    (h3 {}, "Links"),
    div {}, items

Body = (data) ->
  body({},
    (h3 {}, "Raw JSON"),
    (code {}, JSON.stringify(data, null, '\t')),
    (h3 {}, "Contents"),
    (JsonTable data),
    (LinkSection data)
  )

provide 'view/jsonDump', -> (data) ->
  title: getTitle(data)
  body: Body(data)


React = require('react')

{body,div,table,td,tr,h3,code,a} = React.DOM

JsonTable = (value) ->
  rows = for k,v of value
    if ObjectUtil.isObject(v)
      v = JSON.stringify(v)
    tr {key:k}, (td {}, k), (td {}, v)
  table {className: "table table-striped"}, rows

getTitle = (value) ->
  value.name ? ''

getLinks = (value) ->
  if value.type == 'Place'
    return {
      'Details': "/api/place/#{value.place_id}/details"
      'Factual source': 'http://factual.com/'+value.factual_id
    }
  {}

LinkList = (value) ->
  items = for name, url of getLinks(value)
    a {key:name, className: 'btn btn-default', href: url}, name
  div {}, items

class HtmlPresentation

  body: (value) ->
    body({},
      (h3 {}, "Raw JSON"),
      (code {}, JSON.stringify(value, null, '\t')),
      (h3 {}, "Contents"),
      (JsonTable value),
      (h3 {}, "Links"),
      (LinkList value)
    )
    

  render: (value) ->
    """
    <html>
      <head>
        <title>#{getTitle(value)}</title>
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">
      </head>
      #{React.renderToStaticMarkup(@body(value))}
    </html>
    """

provide('HtmlPresentation', HtmlPresentation)

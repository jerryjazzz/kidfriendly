
class HtmlPresentation
  render: (type, value) ->
    """
    <html>
      <head>
      </head>
      <body>
        <div>
          #{JSON.stringify(value, null, "\t")}
        </div>
      </body>
    </html>
    """

provide('HtmlPresentation', HtmlPresentation)

'use strict'
HoursDirective = ->
  scope:
    "hours":"="
  restrict:"E"
  template:"""
  <p>{{openText(hours)}}</p>
  """
  link:(scope,elem,attr)->
    allHoursInTwelveHourFormat = (hours) ->
      results = []
      for key, hour of hours
        result = ""
        result += hoursInTwelveHourFormat(hour[0])
        result += " - "
        result += hoursInTwelveHourFormat(hour[1])
        results.push(result)
      results[0]

    hoursInTwelveHourFormat = (hour) ->
      return unless hour?.indexOf(":") != -1
      hoursAsInt = parseInt(hour.substr(0, hour.indexOf(":")))
      if hoursAsInt > 12
        return "#{hoursAsInt-12}#{hour.substr(hour.indexOf(":"))}pm"
      else if hoursAsInt == 0
        return "12#{hour.substr(hour.indexOf(":"))}am"
      else
        return "#{hour}am"

    scope.openText = (hours) ->
      return unless hours?
      days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
      now = new Date(Date.now())
      todaysHours = hours[days[now.getDay()]]
      if todaysHours?
        return "Open: #{allHoursInTwelveHourFormat(todaysHours)}"
      else
        return "Closed"

angular.module('Mobile').directive 'kfHours', HoursDirective
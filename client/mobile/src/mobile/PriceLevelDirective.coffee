'use strict'
PriceLevelDirective = ->
  scope:
    "level":"="
  restrict:"E"
  template:"""
  <i ng-repeat="i in getLength(level) track by $index" class="fa fa-usd cash-icon"></i>
  """
  link:(scope,elem,attr)->
    scope.getLength = (level) ->
      return new Array(level) if level?
      return undefined

angular.module('Mobile').directive 'kfPriceLevel', PriceLevelDirective
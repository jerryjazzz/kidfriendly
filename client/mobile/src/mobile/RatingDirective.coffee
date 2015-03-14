'use strict'
RatingDirective = ->
  scope:
    "rating":"="
    "bannerClass": "="
  restrict:"E"
  transclude:true
  template:"""
  <div ng-transclude class="{{bannerClass}}" ng-class="ratingStyle(rating)"></div>
  """
  link:(scope,elem,attr)->
    scope.ratingStyle = ->
      rating = scope.rating
      style =
        "rating-bad": rating < 60
        "rating-average": rating >= 60 and rating < 80
        "rating-good": rating >= 80
      style
angular.module('Mobile').directive 'kfRating', RatingDirective
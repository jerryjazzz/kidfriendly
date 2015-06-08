'use strict'
RatingDirective = ->
  scope:
    "rating":"="
    "bannerClass": "="
  restrict:"E"
  transclude:true
  template:"""
  <div ng-transclude class="{{bannerClass}}" ng-class="ratingClass"></div>
  """
  link:(scope,elem,attr)->
    getRatingClass= ->
      rating = scope.rating
      style =
        "rating-bad": rating < 0
        "rating-average": rating == 0 or rating == "-"
        "rating-good": rating > 0
      scope.ratingClass = style
    getRatingClass()
    scope.$watch 'rating', getRatingClass



angular.module('Mobile').directive 'kfRating', RatingDirective
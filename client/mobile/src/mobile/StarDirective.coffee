StarsDirective = ->
  scope:
    "ngModel":"="
    "max":"="
    acceptInput:"="
  restrict:"EA"
  template:"""
              <div ng-if="!acceptInput">
                <i class="fa fa-star kf-blue-star" ng-repeat="star in stars"></i>
                <i class="fa fa-star-half kf-blue-star" ng-if="halfStar"></i>
              </div>
              <div ng-if="acceptInput" class="button-bar">
                <a class="button button-clear" ng-repeat="star in stars" ng-click="setVal(star)">
                  <i class="fa fa-star kf-grey-star" ng-class="{'kf-grey-star':$index>=ngModel, 'kf-blue-star':$index<ngModel}"></i>
                </a>
              </div>
  """
  require:"ngModel"
  link:(scope,elem,attr)->
    scope.halfStar = (scope.ngModel - Math.floor scope.ngModel) >= .5
  controller:($scope)->
    if $scope.acceptInput
      $scope.stars= [1..$scope.max]
    else
      $scope.stars = [1..$scope.ngModel]

    $scope.setVal=(index)->
      if($scope.readonly)
        return
      if($scope.ngModel==index==1)
        $scope.ngModel=0
      else
        $scope.ngModel=index

angular.module('Mobile').directive 'kfStars',StarsDirective
StarsDirective = ->
  scope: "ngModel":"=","max":"="
  restrict:"EA"
  template:"""<div class="button-bar">
                <a class="button button-clear" ng-repeat="star in stars" ng-click="setVal(star)">
                  <i class="fa fa-star kf-grey-star" ng-class="{'kf-grey-star':$index>=ngModel, 'kf-blue-star':$index<ngModel}"></i>
                </a>
              </div>
  """
  require:"ngModel"
  link:(scope,elem,attr)->
    scope.ngModel=parseInt(attr.value, 10) if(attr.value) #set default value
  controller:($scope)->
    console.log 'controller', $scope
    $scope.stars=[1..$scope.max]#coffee shortcut for make an array
    $scope.setVal=(index)->
      if($scope.readonly)
        return
      if($scope.ngModel==index==1)
        $scope.ngModel=0
      else
        $scope.ngModel=index

angular.module('Mobile').directive 'kfStars',StarsDirective
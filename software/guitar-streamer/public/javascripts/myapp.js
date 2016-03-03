var angular = require('angular');
var spinner = require('angular-spinner');
var app = angular.module('guitar', ['angularSpinner']);

app.controller('MyController', ['$scope', function($scope){
	var playerShouldBeVisible = true;
	audioIsAvailable = function(){
		return playerShouldBeVisible;
	};
	setAudioAvailable = function(){
//		playerShouldBeVisible = true;
	};
	
}]);

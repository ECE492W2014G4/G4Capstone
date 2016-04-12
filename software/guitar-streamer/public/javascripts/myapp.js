var angular = require('angular');
var spinner = require('angular-spinner');
var app = angular.module('guitar', ['angularSpinner']);

app.factory('audioListener',function(){
	return {
		canPlay: {
			audioAvailable:false
		}	
	}
});

app.directive('audioDirective',['$compile', 'audioListener', function($compile, audioListener){
	return {
		link: function(scope, element,attrs){
			element.find("audio").on('canPlay',function(){
				audioListener.audioAvailable = true;			
			});
		}
	}
}]);

app.controller('MyController', ['$scope', 'audioListener', function($scope,audioListener){
	audioIsAvailable = function(){	
		return audioListener.audioAvailable;
	};
}]);

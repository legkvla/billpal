#= require_self

angular
  .module('billpal', ['ngResource'])
  .config([
    '$httpProvider',
    ($httpProvider) ->
      $httpProvider.defaults.headers.patch = { 'Content-Type': 'application/json' }

      metas = document.getElementsByTagName 'meta'
      for meta in metas
        $httpProvider.defaults.headers.common['X-CSRF-Token'] = meta.content if meta.name == 'csrf-token'
  ])
  .config([
      '$locationProvider',
      ($locationProvider) ->
        $locationProvider.html5Mode true
  ])
  .config([
    '$routeProvider',
    ($routeProvider) ->
      #
  ])

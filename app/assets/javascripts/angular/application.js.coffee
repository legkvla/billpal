#= require_self

angular
  .module('transfers', ['ngResource'])
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
      #
  ])
  .controller('TransfersController', [
    '$scope'
    '$resource'
    ($scope, $resource) ->
      $scope.step = 'verificatePhone'
      $scope.data = {}

      $scope.verificatePhone = ->
        $resource(Routes.api_v1_verificators_verificate_path()).save
          phone_number: $scope.data.phone_number
          (response) ->
            $scope.verificationCodeNotSent = null
            #$scope.verificationCodeSent = true
            $scope.step = 'verificateCode'
          (response) ->
            $scope.verificationCodeNotSent = response.data.status

      $scope.verificateCode = ->
        $resource(Routes.api_v1_verificators_verification_code_path()).save
          code: $scope.data.verification_code
          phone_number: $scope.data.phone_number
          (response) ->
            $scope.phoneNotVerified = null
            #$scope.phoneVerified = true
            $scope.step = 'checkReceiverContacts'
          (response) ->
            $scope.phoneNotVerified = response.data.status

      $scope.checkReceiverContacts = ->
        # TODO

  ])

angular
  .module('billpal', ['transfers'])
  .controller('RootController', [
    '$scope'
    ($scope) ->
      #
  ])

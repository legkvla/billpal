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

  .controller('TransfersController', [
    '$scope'
    '$resource'
    ($scope, $resource) ->
      paysioKey = null
      $scope.setPaysioKey = (key) -> paysioKey = key

      $scope.step = 'verificatePhone'
      $scope.setStep = (step) -> $scope.step = step
      $scope.data = {}

      $scope.verificatePhone = ->
        $resource(Routes.api_v1_verificators_verificate_path()).save
          phone_number: $scope.data.phone_number
          (response) ->
            $scope.verificationCodeNotSent = null
            #$scope.verificationCodeSent = true
            $scope.setStep 'verificateCode'
          (response) ->
            $scope.verificationCodeNotSent = response.data.status

      $scope.verificateCode = ->
        $resource(Routes.api_v1_verificators_verification_code_path()).save
          code: $scope.data.verification_code
          phone_number: $scope.data.phone_number
          (response) ->
            $scope.phoneNotVerified = null
            #$scope.phoneVerified = true
            $scope.setStep 'checkReceiverContacts'
          (response) ->
            $scope.phoneNotVerified = response.data.status

      $scope.checkReceiverContacts = ->
        $resource(Routes.api_v1_transfers_path()).save
          payment_method: 'test'
          amount: $scope.data.charge_amount
          contact_to_kind: $scope.data.contact_type
          contact_to_uid: $scope.data["contact_#{$scope.data.contact_type}"]
          phone_number: $scope.data.phone_number
          (response) ->
            $scope.contactsNotChecked = null
            #$scope.verificationCodeSent = true
            $scope.setStep 'paysioRequest'

            Paysio.setPublishableKey(paysioKey)
            Paysio.form.build($('<form />'), { charge_id: response.charge_id });
          (response) ->
            $scope.contactsNotChecked = response.data.status


  ])

angular
  .module('billpal', ['transfers'])
  .config([
    '$locationProvider',
    ($locationProvider) ->
      $locationProvider.html5Mode true
  ])
  .config([
    '$routeProvider',
    (r) ->
      r.when '/profile',
        templateUrl: '/templates/profile_page.html'

      r.when '/balance',
        templateUrl: '/templates/balance.html'
      r.when '/dashboard',
        templateUrl: '/templates/bills.html'
        controller: 'BillsController'

      r.when '/dashboard/transfers_in',
        templateUrl: '/templates/transfers_in.html'
        controller: 'TransfersController'

      r.when '/dashboard/transfers_out',
        templateUrl: '/templates/transfers_out.html'
        controller: 'TransfersController'

      r.when '/dashboard/people',
        templateUrl: '/templates/people.html'
        controller: 'PeopleController'

      r.when '/dashboard/bill_templates',
        templateUrl: '/templates/bill_templates.html'
        controller: 'BillTemplatesController'

      r.when '/:any',
        template: '<h5>Загрузка</h5>'
        controller: 'RedirectController'

  ])
  .controller('RedirectController', [
    '$location'
    ($location) ->
      location.href = $location.path()
  ])
  .controller('RootController', [
    '$scope'
    '$location'
    ($scope, $location) ->
      $scope.activeClass = (path) ->
        active: if path.filter? then path.filter((v) -> v == $location.path()).length > 0 else $location.path() == path
  ])
  .factory('Bill', [
    '$resource'
    ($resource) ->
      $resource(Routes.api_v1_bill_path(':id'))
  ])
  .controller('BillsController', [
    '$scope'
    ($scope) ->
      #
  ])
  .controller('TransfersController', [
    '$scope'
    ($scope) ->
      #
  ])
  .controller('PeopleController', [
    '$scope'
    ($scope) ->
      #
  ])
  .controller('BillTemplatesController', [
    '$scope'
    ($scope) ->
      #
  ])

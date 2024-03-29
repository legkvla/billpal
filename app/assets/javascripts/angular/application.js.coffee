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

  .controller('WithdrawalsController', [
    '$scope'
    '$resource'
    ($scope, $resource) ->
      $scope.data = {}

      $scope.withdraw = ->
        $resource(Routes.api_v1_withdrawals_path()).save
          amount: $scope.data.withdrawal_amount
          payment_method: $scope.data.withdrawal_to
          payment_data: $scope.data.param
          (response) ->
            $scope.notWithdrawn = null
            location.href = '/dashboard'
          (response) ->
            $scope.notWithdrawn = response.data.status
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
  .module('billpal', ['transfers', 'ui.select2'])
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

      r.when '/invoice_new',
        templateUrl: '/templates/invoice_new.html'

      r.when '/dashboard/show_bill/:id',
        templateUrl: '/templates/invoice_show.html'
        controller: ['$scope', '$routeParams', 'Bill', ($scope, $routeParams, Bill) ->
          $scope.bill = Bill.get id: $routeParams.id
        ]

      r.when '/dashboard',
        templateUrl: '/templates/bills_drafts.html'
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

      r.when '/dashboard/bill_template_form',
        templateUrl: '/templates/bill_template_form.html'
        controller: 'BillTemplatesController'

      r.when '/dashboard/bills_drafts',
        templateUrl: '/templates/bills_drafts.html'
        controller: 'BillsController'

      r.when '/dashboard/bills_canceled',
        templateUrl: '/templates/bills_canceled.html'
        controller: 'BillsController'

      r.when '/dashboard/bills_sent',
        templateUrl: '/templates/bills_sent.html'
        controller: 'BillsController'

      r.when '/dashboard/bills_paid',
        templateUrl: '/templates/bills_paid.html'
        controller: 'BillsController'

      r.when '/dashboard/bill_new',
        templateUrl: '/templates/bill_new.html'
        controller: 'BillsController'

      r.when '/:any',
        template: '<h5>Загрузка</h5>'
        controller: 'RedirectController'

      r.when '/:any/:kind',
        template: '<h5>Загрузка</h5>'
        controller: 'RedirectController'

      r.when '/:any/:kind/:of',
        template: '<h5>Загрузка</h5>'
        controller: 'RedirectController'

      r.when '/:any/:kind/:of/:shit',
        template: '<h5>Загрузка</h5>'
        controller: 'RedirectController'

  ])
  .directive 'contenteditable', ->
    require: '?ngModel'
    link: (scope, element, attr, ngModel) ->
      return unless ngModel

      if element[0].tagName.toLowerCase() == 'ul'
        ngModel.$render = ->
          val = ngModel.$viewValue
          if val
            element.html('')
            for line in val.split /\n/
              element.append(angular.element('<li></li>').text(line))
          else
            element.html('')
            element.append(angular.element('<li></li>'))

        getVal = -> (angular.element(li).text() for li in element.children()).join('\n').trim()

        element.bind 'keydown', (event) -> event.preventDefault() if not getVal() and event.keyCode is 8
        element.bind 'input', -> scope.$apply -> ngModel.$setViewValue(getVal())
      else
        ngModel.$render = -> element.text(ngModel.$viewValue)

        getVal = -> element.text()

        element.bind 'keydown', (event) -> event.preventDefault() if event.keyCode is 13
        element.bind 'input', -> scope.$apply -> ngModel.$setViewValue(getVal())
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

      $scope.invoiceClass = null

      $scope.invoiceClassSelector = (selector) ->
        'lightblue' if selector == $scope.invoiceClass

      $scope.setInvoiceFilter = (selector) ->
        $scope.invoiceClass = selector

  ])
  .factory('Bill', [
    '$resource'
    ($resource) ->
      $resource(Routes.api_v1_bill_path(':id').replace(/\.json$/, '') + '/:kind',
        { id: '@id' },
        pay:
          method: 'POST'
          params:
            kind: 'pay'
        cancel:
          method: 'POST'
          params:
            kind: 'cancel'
        expose:
          method: 'POST'
          params:
            kind: 'expose'
      )
  ])
  .controller('BillsController', [
    '$scope'
    'Bill'
    '$location'
    '$filter'
    ($scope, Bill, $location, $filter) ->
      $scope.bills = Bill.query {}

      $scope.count = (state) ->
        $filter('filter')($scope.bills, state: state).length

      $scope.sum_cents = (filter) ->
        data = $filter('filter')($scope.bills, filter)
        acc = 0
        acc += datum.amount_cents for datum in data
        acc

      $scope.new_bill =
        items_attributes: []
        to_user_attributes: {}

      $scope.createBill = (bill) ->
        bill = if bill then new Bill(bill) else new Bill(created_at: new Date())

        $scope.bills.push(bill)
        bill.$save()

        $location.path('/dashboard')


      $scope.userSelect =
        allowClear: true
        ajax:
          url: Routes.api_v1_relationships_path()
          data: () -> {}
          results: (data, page) -> { results: { id: datum.id, text: "#{datum.first_name} #{datum.last_name}" } for datum in data }

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
  .controller('InvoicesController', [
    '$scope'
    ($scope) ->


  ])

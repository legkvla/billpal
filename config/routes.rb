require 'sidekiq/web'

Billpal::Application.routes.draw do

	devise_for :users, :path => 'accounts',
						 :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks', :registrations => 'registrations' }

  get 'dashboard(/:any_action)' => 'dashboard#index', as: :dashboard

  resources :transfers do
    member do
      get 'from_email/*slug', action: :from_email, as: :from_email
    end
  end

  resources :templates

  namespace :management do
    check_for_admin = lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.admin? }
    constraints check_for_admin do
      mount Sidekiq::Web => '/sidekiq', as: :sidekiq
    end
  end

  namespace :api do
    namespace :v1 do
      resources :transfers do
        member do
          post :withdrawal
        end
      end

      resources :bills
      resources :contacts

      # Verificators
      post 'verificators/verificate' => 'verificators#verificate'
      post 'verificators/verification_code' => 'verificators#verification_code'
    end
  end

  namespace :returns do
    get 'paysio' => 'paysio#return'

    get 'email/*slug' => 'email#verification_slug', as: :email_verification_slug
  end

  root to: 'pages#index'
end

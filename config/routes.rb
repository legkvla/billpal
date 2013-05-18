require 'sidekiq/web'

Billpal::Application.routes.draw do
  devise_for :users

  namespace :management do
    check_for_admin = lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.admin? }
    constraints check_for_admin do
      mount Sidekiq::Web => '/sidekiq', as: :sidekiq
    end
  end

  namespace :api do
    namespace :v1 do
      resources :payment_transfers do

      end


      # Verificators
      post 'verificators/verificate' => 'verificators#verificate'
      post 'verificators/verification_code' => 'verificators#verification_code'
    end
  end

  root to: 'pages#index'
end

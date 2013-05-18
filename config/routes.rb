Billpal::Application.routes.draw do

	devise_for :users, :path => "accounts",
						 :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "registrations" }

  resources :dashboard

  namespace :api do
    namespace :v1 do
      resources :payment_transfers
    end
  end

  root to: 'pages#index'
end

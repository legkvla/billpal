Billpal::Application.routes.draw do
  devise_for :users

  resources :dashboard

  root to: 'pages#index'
end

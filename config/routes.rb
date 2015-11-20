Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    resources :users, only: [:create]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resources :passwords
  end
end
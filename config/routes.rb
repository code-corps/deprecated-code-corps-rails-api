Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    resources :users, only: [:create]
    resources :passwords
  end
end
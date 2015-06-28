Rails.application.routes.draw do
  use_doorkeeper

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    resources :users, only: [:create]
  end
end

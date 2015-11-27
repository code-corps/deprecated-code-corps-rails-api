Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    get 'user', to: 'users#show_authenticated_user'
    resources :users, only: [:create, :show]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resource :users, only: [:forgot_password] do
      post :forgot_password
    end

    resources :projects, only: [:show, :index, :create, :update]
  end
end

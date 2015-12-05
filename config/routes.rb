Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    resources :comments, only: [:create]

    resources :projects, only: [:index]

    get 'user', to: 'users#show_authenticated_user'
    patch 'users/me', to: 'users#update_authenticated_user'
    resources :users, only: [:create, :show, :update]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resource :users, only: [:forgot_password] do
      post :forgot_password
    end
    resources :post_likes, only: [:create, :destroy]
    resources :user_skills, only: [:create, :destroy]
    resources :projects, only: [:show, :index, :create, :update]

    resources :organizations, only: [:show]

    resources :skill_categories, only: [:index]

    resources :members, :path => '', :only => [:show] do
      resources :projects, :path => '', :only => [:show, :create, :update] do
        resources :posts, only: [:index, :show, :create]
      end
    end
  end
end

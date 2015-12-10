Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    get 'user', to: 'users#show_authenticated_user'
    patch 'users/me', to: 'users#update_authenticated_user'
    resources :users, only: [:show, :create, :update]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resource :users, only: [:forgot_password] do
      post :forgot_password
    end
    resources :post_likes, only: [:create, :destroy]
    resources :user_skills, only: [:create, :destroy]
    resources :github_repositories, only: [:create]

    resources :contributors, only: [:index, :create, :update]

    resources :skill_categories, only: [:index]

    resources :projects, only: [:index, :create, :update] do
        resources :posts, only: [:index, :show]
    end

    resources :posts, only: [:create, :update] do
      resources :comments, only: [:index]
    end

    resources :comments, only: [:show, :create, :update]

    resources :organizations, only: [:show, :create, :update]

    resources :members, :path => '', :only => [:show] do
      resources :projects, :path => '', :only => [:show]
    end
  end
end

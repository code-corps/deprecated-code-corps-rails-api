require "constraints/slug_constraint"

Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: 'tokens'
  end

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

    resources :comments, only: [:create]

    resources :posts, only: [:index, :show, :create]

    resources :projects, only: [:show, :index, :create, :update]

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
    resources :github_repositories, only: [:create]

    resources :organizations, only: [:show]

    resources :skill_categories, only: [:index]

    # Users goes before organizations since there are vastly more users to match
    get '/:slug', to: 'users#show', constraints: SlugConstraint.new(User)
    get '/:slug', to: 'organizations#show', constraints: SlugConstraint.new(Organization)
    get '*unmatched_route', :to => 'application#raise_not_found!'
  end
end

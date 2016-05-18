Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: "tokens"
  end

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  constraints subdomain: "api" do
    get "ping", to: "ping#index"

    get "user", to: "users#show_authenticated_user"
    patch "users/me", to: "users#update_authenticated_user"
    resources :users, only: [:show, :create, :update]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resource :users, only: [:forgot_password] do
      post :forgot_password
    end

    resources :skills, only: [:index, :create]

    resources :post_likes, only: [:create, :destroy]
    resources :user_skills, only: [:create, :destroy]
    resources :github_repositories, only: [:create]

    resources :roles, only: [:index]

    resources :projects, only: [:index, :create, :update] do
      resources :posts, only: [:index, :show]
    end

    resources :posts, only: [:create, :update] do
      resources :comments, only: [:index]
    end

    resources :post_images, only: [:create]

    resources :comments, only: [:show, :create, :update]

    resources :comment_images, only: [:create]

    resources :organizations, only: [:show, :create, :update]

    resources :post_user_mentions, only: [:index]
    resources :comment_user_mentions, only: [:index]

    resources :slugged_routes, path: "", only: [:show] do
      get "projects", to: "projects#index"
      resources :projects, path: "", only: [:show]
    end
  end

  get "/(*path)" => "ember_index#index", as: :root, format: :html
end

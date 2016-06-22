Rails.application.routes.draw do
  use_doorkeeper do
    controllers tokens: "tokens"
  end

  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  constraints subdomain: "api" do
    resources :categories, only: [:index, :show, :create]

    resources :comments, only: [:show, :create, :update]
    resources :comment_images, only: [:create]
    resources :comment_user_mentions, only: [:index]

    resources :github_repositories, only: [:create]

    resources :organizations, only: [:show, :create, :update] do
      get "memberships", to: "organization_memberships#index"
    end
    resources :organization_memberships, only: [:show, :create, :update, :destroy]

    get "ping", to: "ping#index"

    resources :posts, only: [:create, :update] do
      resources :comments, only: [:index]
    end
    resources :post_images, only: [:create]
    resources :post_likes, only: [:create, :destroy]
    resources :post_user_mentions, only: [:index]

    resources :previews, only: [:create]
    resources :preview_user_mentions, only: [:index]

    resources :projects, only: [:index, :create, :update] do
      resources :posts, only: [:index, :show]
    end
    resources :project_categories, only: [:create, :destroy]
    resources :project_roles, only: [:create, :destroy]
    resources :project_skills, only: [:create, :destroy]

    resources :roles, only: [:index, :create]
    resources :role_skills, only: [:create]

    resources :skills, only: [:index, :create]
    get "skills/search", to: "skills#search"

    get "user", to: "users#show_authenticated_user"
    get "users/email_available", to: "users#email_available"
    get "users/username_available", to: "users#username_available"
    patch "users/me", to: "users#update_authenticated_user"
    resources :users, only: [:show, :create, :update]
    resource :users, only: [:reset_password] do
      post :reset_password
    end
    resource :users, only: [:forgot_password] do
      post :forgot_password
    end

    resources :user_categories, only: [:show, :create, :destroy]
    resources :user_roles, only: [:show, :create, :destroy]
    resources :user_skills, only: [:index, :create, :destroy]

    resources :slugged_routes, path: "", only: [:show] do
      get "projects", to: "projects#index"
      resources :projects, path: "", only: [:show]
    end
  end

  get "/(*path)" => "ember_index#index", as: :root, format: :html
end

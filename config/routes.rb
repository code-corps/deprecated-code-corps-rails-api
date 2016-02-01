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

    resources :skill_categories, only: [:index]

    resources :post_images, only: [:create]

    resources :comment_images, only: [:create]

    resources :organizations, only: [:show, :create, :update]

    resources :slugged_routes, path: '', only: [:show] do
      get "projects", to: "projects#index"
      resources :projects, path: '', only: [:show, :create, :update] do
        resources :posts, only: [:index, :show, :create, :update] do
          resources :comments, only: [:index, :create, :update]
        end
      end
    end
  end

  get '/(*path)' => "ember_index#index", as: :root, format: :html
end

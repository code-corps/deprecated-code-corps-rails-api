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

    class OrganizationUrlConstrainer
      def matches?(request)
        slug = request.path.gsub("/", "")
        Organization.find_by_slug(slug)
      end
    end

    constraints(OrganizationUrlConstrainer.new) do
      get '/:slug', to: "organizations#show", as: 'short_organization'
    end

    class UserUrlConstrainer
      def matches?(request)
        slug = request.path.gsub("/", "")
        User.find_by_slug(slug)
      end
    end

    constraints(UserUrlConstrainer.new) do
      get '/:slug', to: "users#show", as: 'short_user'
    end

  end
end

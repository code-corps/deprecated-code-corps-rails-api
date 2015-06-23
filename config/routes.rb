Rails.application.routes.draw do
  use_doorkeeper

  constraints subdomain: 'api' do

    get 'ping', to: 'ping#index'

  end
end

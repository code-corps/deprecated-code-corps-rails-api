FactoryGirl.define do

  factory :oauth_token, :class => Doorkeeper::AccessToken do
    association :application, :factory => :oauth_application
    association :resource_owner_id, :factory => :user
  end

end
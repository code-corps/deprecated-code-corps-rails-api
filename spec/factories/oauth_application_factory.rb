FactoryGirl.define do

  factory :oauth_application, :class => Doorkeeper::Application do
    sequence(:name) { |n| "application_name_#{n}" }
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
  end

end
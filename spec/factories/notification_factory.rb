FactoryGirl.define do

  factory :notification do
    association :user
    association :notifiable
  end

end

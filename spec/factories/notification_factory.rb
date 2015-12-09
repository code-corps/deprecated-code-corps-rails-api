FactoryGirl.define do

  factory :notification do
    association :user
    association :notifiable, factory: :post
  end

end

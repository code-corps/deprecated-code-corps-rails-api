FactoryGirl.define do

  factory :post_user_mention do
    association :user
    association :post

    sequence(:start_index) { |n| n }
    sequence(:end_index) { |n| n }
  end

end

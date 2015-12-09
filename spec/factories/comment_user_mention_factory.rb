FactoryGirl.define do

  factory :comment_user_mention do
    association :user
    association :comment
    association :post

    sequence(:start_index) { |n| n }
    sequence(:end_index) { |n| n }
  end

end

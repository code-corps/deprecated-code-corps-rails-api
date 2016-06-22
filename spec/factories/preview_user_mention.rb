FactoryGirl.define do
  factory :preview_user_mention do
    association :user
    association :preview

    sequence(:start_index) { |n| n }
    sequence(:end_index) { |n| n }
  end
end

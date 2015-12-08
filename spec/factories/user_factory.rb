FactoryGirl.define do

  factory :user do |user|
    sequence(:email) { |n| "test#{n}@tester.com" }
    sequence(:username) { |n| "tester#{n}" }
    password "password"
  end

  trait :with_s3_photo do
    after(:build) do |user, evaluator|
      user.photo_file_name = 'user.jpg'
      user.photo_content_type = 'image/jpeg'
      user.photo_file_size = 1024
      user.photo_updated_at = Time.now
    end
  end

end

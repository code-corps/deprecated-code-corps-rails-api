# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  name                  :text
#  aasm_state            :string           default("signed_up"), not null
#

FactoryGirl.define do

  factory :user do |user|
    sequence(:email) { |n| "test#{n}@tester.com" }
    sequence(:username) { |n| "tester#{n}" }
    password "password"
  end

  trait :admin do
    admin true
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

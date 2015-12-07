FactoryGirl.define do

  factory :member do
    sequence(:slug) { |n| "slug#{n}" }

    association :model
  end

  factory :organization_member, class: "Member" do
    sequence(:slug) { |n| "slug#{n}" }

    association :model, factory: :organization
  end

  factory :user_member, class: "Member" do
    sequence(:slug) { |n| "slug#{n}" }

    association :model, factory: :user
  end
end

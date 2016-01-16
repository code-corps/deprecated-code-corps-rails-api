FactoryGirl.define do
  factory :organization_membership do |f|
    association :member, factory: :user
    association :organization
  end
end

FactoryGirl.define do

  factory :skill_category do
    sequence(:title) { |n| "Category #{n}" }
  end

end

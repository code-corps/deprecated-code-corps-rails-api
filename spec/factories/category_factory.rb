FactoryGirl.define do

  factory :category do
    sequence(:title) { |n| "Category #{n}" }
  end

end

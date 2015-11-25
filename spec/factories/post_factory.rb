FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
  end

end

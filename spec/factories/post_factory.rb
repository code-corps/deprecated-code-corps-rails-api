FactoryGirl.define do

  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    sequence(:body) { |n| "Post body #{n}" }
  end

end

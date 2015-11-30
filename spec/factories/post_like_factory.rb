FactoryGirl.define do

  factory :post_like do
    after(:build) do |post, evaluator|
      post.user = evaluator.user || build(:user)
      post.post = evaluator.post || build(:post)
    end
  end

end

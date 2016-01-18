# == Schema Information
#
# Table name: contributors
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  status     :string           default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do

  factory :contributor do
    status "pending"

    association :project
    association :user
  end

end

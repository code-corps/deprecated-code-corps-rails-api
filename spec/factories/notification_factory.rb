# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  notifiable_id   :integer          not null
#  notifiable_type :string           not null
#  user_id         :integer          not null
#  aasm_state      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do

  factory :notification do
    association :user
    association :notifiable, factory: :post
  end

end

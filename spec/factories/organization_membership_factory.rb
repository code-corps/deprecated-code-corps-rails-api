# == Schema Information
#
# Table name: organization_memberships
#
#  id              :integer          not null, primary key
#  role            :string           default("regular"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#  organization_id :integer
#

FactoryGirl.define do

  factory :organization_membership do |f|
    association :member, factory: :user
    association :organization
  end

end

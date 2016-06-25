# == Schema Information
#
# Table name: organization_memberships
#
#  id              :integer          not null, primary key
#  role            :string           default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#  organization_id :integer
#

class OrganizationMembershipSerializer < ActiveModel::Serializer
  attributes :id, :role

  belongs_to :member
  belongs_to :organization
end

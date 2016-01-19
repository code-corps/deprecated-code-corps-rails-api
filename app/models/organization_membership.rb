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

class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :organization_id

  enum role: {
    pending: "pending",
    contributor: "contributor",
    admin: "admin",
    owner: "owner"
  }
end

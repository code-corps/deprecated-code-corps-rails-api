class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :member, class_name: "User"

  validates_uniqueness_of :member_id, scope: :organization_id

  enum role: {
    regular: "regular",
    admin: "admin"
  }
end

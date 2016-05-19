class OrganizationMembershipSerializer < ActiveModel::Serializer
  attributes :id, :role

  belongs_to :member
  belongs_to :organization
end

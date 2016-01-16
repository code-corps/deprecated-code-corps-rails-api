class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :members
  has_many :projects
end

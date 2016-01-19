# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string           not null
#

class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :members
  has_many :projects
end

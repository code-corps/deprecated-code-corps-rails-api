# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#  kind       :string           not null
#

class RoleSerializer < ActiveModel::Serializer
  attributes :id, :name, :ability, :kind

  has_many :skills
end

# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  model_id   :integer
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MemberSerializer < ActiveModel::Serializer
  attributes :id, :slug

  belongs_to :model
end

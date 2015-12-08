class MemberSerializer < ActiveModel::Serializer
  attributes :id, :slug

  belongs_to :model
end

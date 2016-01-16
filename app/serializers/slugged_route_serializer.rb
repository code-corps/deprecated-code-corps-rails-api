class SluggedRouteSerializer < ActiveModel::Serializer
  attributes :id, :slug

  belongs_to :owner
end

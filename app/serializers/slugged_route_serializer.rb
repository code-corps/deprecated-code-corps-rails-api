# == Schema Information
#
# Table name: slugged_routes
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SluggedRouteSerializer < ActiveModel::Serializer
  attributes :id, :slug, :owner_type

  belongs_to :owner
end

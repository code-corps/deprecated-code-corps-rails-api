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

class SluggedRoute < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates_presence_of :slug
  validates_exclusion_of :slug, in: Rails.configuration.x.reserved_routes
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
end

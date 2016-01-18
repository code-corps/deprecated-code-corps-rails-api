class SluggedRoute < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates_presence_of :slug
  validates_exclusion_of :slug, in: Rails.configuration.x.reserved_routes
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
end

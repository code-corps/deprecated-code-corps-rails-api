class SlugRoute < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates_presence_of :slug
  validates :slug, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
end

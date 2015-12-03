class SlugRoute < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates_presence_of :slug
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
end

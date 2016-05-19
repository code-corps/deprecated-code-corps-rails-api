class Category < ActiveRecord::Base
  before_validation :add_slug_if_blank

  validates :name, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: { case_sensitive: false }
  validates :slug, slug: true

  private

    def add_slug_if_blank
      self.slug = name.try(:parameterize) unless slug.present?
    end
end

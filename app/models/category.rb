# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class Category < ActiveRecord::Base
  has_many :project_categories
  has_many :projects, through: :project_categories

  before_validation :add_slug_if_blank

  validates :name, presence: true
  validates :slug, presence: true,
                   slug: true,
                   uniqueness: { case_sensitive: false }

  private

    def add_slug_if_blank
      self.slug = name.try(:parameterize) unless slug.present?
    end
end

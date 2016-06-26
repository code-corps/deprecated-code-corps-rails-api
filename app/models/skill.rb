# == Schema Information
#
# Table name: skills
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :string
#  original_row :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Skill < ActiveRecord::Base
  searchkick match: :word_start, searchable: [:title]

  has_many :role_skills
  has_many :roles, through: :role_skills

  validates_presence_of :title

  before_validation :update_slug

  validates :slug, presence: true
  validates :slug, obscenity: { message: "may not be obscene" }
  validates :slug, exclusion: { in: Rails.configuration.x.reserved_routes }
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }

  def self.autocomplete(query)
    results = search query
    results.take(5)
  end

  private

    def update_slug
      self.slug = title.try(:parameterize) if title_changed?
    end
end

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

  def self.autocomplete(query)
    results = search query
    results.take(5)
  end
end

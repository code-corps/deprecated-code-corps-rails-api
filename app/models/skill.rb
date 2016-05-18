# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :string
#  role_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Skill < ActiveRecord::Base
  has_many :role_skills
  has_many :roles, through: :role_skills

  validates_presence_of :title
end

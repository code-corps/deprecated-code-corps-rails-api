# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#

class Role < ActiveRecord::Base
  has_many :role_skills
  has_many :skills, through: :role_skills
end

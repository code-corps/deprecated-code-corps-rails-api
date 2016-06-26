# == Schema Information
#
# Table name: skills
#
#  id           :integer          not null, primary key
#  title        :string           not null
#  description  :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  original_row :integer
#  slug         :string           not null
#

class SkillSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :roles
end

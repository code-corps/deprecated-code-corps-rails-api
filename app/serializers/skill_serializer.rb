class SkillSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  belongs_to :skill_category
end

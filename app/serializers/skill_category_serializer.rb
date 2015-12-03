class SkillCategorySerializer < ActiveModel::Serializer
  attributes :id, :title

  has_many :skills
end

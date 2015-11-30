class UserSkillSerializer < ActiveModel::Serializer
  belongs_to :user
  belongs_to :skill
end

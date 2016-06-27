# == Schema Information
#
# Table name: import_skill_failures
#
#  id         :integer          not null, primary key
#  import_id  :integer          not null
#  skill_id   :integer
#  data       :json             not null
#  issues     :text             not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ImportSkillFailureSerializer < ActiveModel::Serializer
  attributes :id, :issues, :data

  belongs_to :skill
  belongs_to :import
end

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

class ImportSkillFailure < ActiveRecord::Base
  belongs_to :import
  belongs_to :skill

  validates :import, presence: true
  validates :issues, presence: true
  validates :data, presence: true
end

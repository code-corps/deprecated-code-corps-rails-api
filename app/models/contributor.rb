# == Schema Information
#
# Table name: contributors
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  project_id :integer
#  status     :string           default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Contributor < ActiveRecord::Base
  belongs_to :user
  belongs_to :project, counter_cache: true

  validates_presence_of :user
  validates_presence_of :project
  validates_presence_of :status
  validates_uniqueness_of :user_id, scope: :project_id

  enum status: {
    pending: "pending",
    collaborator: "collaborator",
    admin: "admin",
    owner: "owner"
  }
end

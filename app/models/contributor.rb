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

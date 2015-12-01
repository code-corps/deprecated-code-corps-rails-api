class Contributor < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates_presence_of :user
  validates_presence_of :project
  validates_presence_of :status

  enum status: {
    pending: "pending",
    collaborator: "collaborator",
    admin: "admin",
    owner: "owner"
  }
end

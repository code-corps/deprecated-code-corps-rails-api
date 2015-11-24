class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many :comments

  enum status: {
    open: "open",
    closed: "closed"
  }

  enum type: {
    idea: "idea",
    progress: "progress",
    task: "task",
    issue: "issue"
  }
end

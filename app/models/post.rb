class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many :comments
  has_many :post_likes

  validates_presence_of :project
  validates_presence_of :user
  validates_presence_of :title
  validates_presence_of :body

  enum status: {
    open: "open",
    closed: "closed"
  }

  enum post_type: {
    idea: "idea",
    progress: "progress",
    task: "task",
    issue: "issue"
  }
end

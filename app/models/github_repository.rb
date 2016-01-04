class GithubRepository < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project
  validates_presence_of :repository_name
  validates_presence_of :owner_name
end

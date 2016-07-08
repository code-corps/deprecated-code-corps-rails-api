# == Schema Information
#
# Table name: github_repositories
#
#  id              :integer          not null, primary key
#  repository_name :string           not null
#  owner_name      :string           not null
#  project_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class GithubRepository < ApplicationRecord
  belongs_to :project

  validates_presence_of :project
  validates_presence_of :repository_name
  validates_presence_of :owner_name
end

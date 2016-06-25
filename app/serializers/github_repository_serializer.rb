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

class GithubRepositorySerializer < ActiveModel::Serializer
  attributes :id, :owner_name, :repository_name

  belongs_to :project
end

class GithubRepositorySerializer < ActiveModel::Serializer
  attributes :id, :owner_name, :repository_name

  belongs_to :project
end

class ContributorSerializer < ActiveModel::Serializer
  attributes :id, :status

  belongs_to :project
  belongs_to :user, serializer: UserSerializerWithoutIncludes
end

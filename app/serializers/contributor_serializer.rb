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

class ContributorSerializer < ActiveModel::Serializer
  attributes :id, :status

  belongs_to :project
  belongs_to :user, serializer: UserSerializerWithoutIncludes
end

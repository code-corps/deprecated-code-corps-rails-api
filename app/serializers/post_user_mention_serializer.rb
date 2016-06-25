# == Schema Information
#
# Table name: post_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PostUserMentionSerializer < ActiveModel::Serializer
  attributes :id, :indices, :username

  belongs_to :user
  belongs_to :post, serializer: PostSerializerWithoutIncludes
end

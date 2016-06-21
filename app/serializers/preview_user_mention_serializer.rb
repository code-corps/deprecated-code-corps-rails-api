# == Schema Information
#
# Table name: preview_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  preview_id  :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PreviewUserMentionSerializer < ActiveModel::Serializer
  attributes :id, :indices, :username

  belongs_to :preview
  belongs_to :user
end

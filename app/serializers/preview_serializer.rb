# == Schema Information
#
# Table name: previews
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  markdown   :text             not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PreviewSerializer < ActiveModel::Serializer
  attributes :id, :body, :markdown

  has_many :preview_user_mentions
end

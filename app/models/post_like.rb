# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PostLike < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates_presence_of :user
  validates_presence_of :post
  validates_uniqueness_of :post_id, scope: :user_id
end


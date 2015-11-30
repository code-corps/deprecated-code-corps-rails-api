class PostLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates_presence_of :user
  validates_presence_of :post
  validates_uniqueness_of :post_id, scope: :user_id
end


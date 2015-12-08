class UserRelationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates_presence_of :follower
  validates_presence_of :followed
  validates_uniqueness_of :follower_id, scope: :followed_id
end

# == Schema Information
#
# Table name: user_relationships
#
#  id           :integer          not null, primary key
#  follower_id  :integer
#  following_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class UserRelationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  validates_presence_of :follower
  validates_presence_of :following
  validates_uniqueness_of :follower_id, scope: :following_id
end

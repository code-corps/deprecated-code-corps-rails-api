class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  validates_presence_of :user
  validates_presence_of :role
  validates_uniqueness_of :user_id, scope: :role_id
end

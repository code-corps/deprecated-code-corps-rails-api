# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates_presence_of :user
  validates_presence_of :role
  validates_uniqueness_of :user_id, scope: :role_id
end

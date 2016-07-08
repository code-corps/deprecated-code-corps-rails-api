# == Schema Information
#
# Table name: user_categories
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserCategory < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user_id, uniqueness: { scope: :category_id }
  validates :user, presence: true
  validates :category, presence: true
end

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

class UserCategory < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :category, required: true

  validates :user_id, uniqueness: { scope: :category_id }
end

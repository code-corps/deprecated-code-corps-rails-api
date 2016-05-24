class UserCategory < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :category, required: true

  validates :user_id, uniqueness: { scope: :category_id }
end

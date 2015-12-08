class Notification < ActiveRecord::Base
  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates_presence_of :notifiable
  validates_presence_of :user
  validates_uniqueness_of :user_id, scope: :notifiable
end

class Notification < ActiveRecord::Base
  belongs_to :notifiable, polymorphic: true

  validates_presence_of :notifiable
end

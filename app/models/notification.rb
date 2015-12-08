class Notification < ActiveRecord::Base
  include AASM

  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  validates_presence_of :notifiable
  validates_presence_of :user
  validates_uniqueness_of :user_id, scope: :notifiable

  aasm do
    state :pending, initial: true
    state :sent
    state :read

    event :dispatch do
      transitions from: :pending, to: :sent
    end

    event :mark_as_read do
      transitions from: [:pending, :sent], to: :read
    end
  end
end

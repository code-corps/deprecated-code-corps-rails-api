# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  notifiable_id   :integer          not null
#  notifiable_type :string           not null
#  user_id         :integer          not null
#  aasm_state      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

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

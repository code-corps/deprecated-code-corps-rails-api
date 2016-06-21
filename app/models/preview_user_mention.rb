# == Schema Information
#
# Table name: preview_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  preview_id  :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PreviewUserMention < ActiveRecord::Base
  belongs_to :preview
  belongs_to :user

  before_validation :add_username_from_user

  validates :end_index, presence: true
  validates :preview, presence: true
  validates :start_index, presence: true
  validates :user, presence: true
  validates :username, presence: true

  def indices
    [start_index, end_index]
  end

  private

    def add_username_from_user
      self.username = user.username if user.present?
    end
end

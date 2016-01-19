# == Schema Information
#
# Table name: post_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PostUserMention < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates_presence_of :user
  validates_presence_of :post
  validates_presence_of :username
  validates_presence_of :start_index
  validates_presence_of :end_index

  before_validation :add_username_from_user

  def indices
    [start_index, end_index]
  end

  private

    def add_username_from_user
      self.username = self.user.username if self.user.present?
    end
end

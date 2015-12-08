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

class User < ActiveRecord::Base
  include Clearance::User

  validates :username, presence: { message: "can't be blank" }
  validates :username, uniqueness: { case_sensitive: false }
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\Z/, message: "is invalid. Alphanumerics only." }, allow_blank: true
  validates :username, length: { maximum: 39 } # This is GitHub's maximum username limit
end

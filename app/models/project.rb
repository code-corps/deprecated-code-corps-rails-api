class Project < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  has_many :posts
end

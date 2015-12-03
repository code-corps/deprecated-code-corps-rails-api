class Slug < ActiveRecord::Base
  belongs_to :sluggable, polymorphic: true
end

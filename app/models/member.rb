# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  model_id   :integer
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Member < ActiveRecord::Base
  belongs_to :model, polymorphic: true

  validates_presence_of :slug
  validates_exclusion_of :slug, in: Rails.configuration.x.reserved_routes
  validates :slug, slug: true
  validates :slug, uniqueness: { case_sensitive: false }
end

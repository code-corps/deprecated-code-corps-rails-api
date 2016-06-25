# == Schema Information
#
# Table name: user_relationships
#
#  id           :integer          not null, primary key
#  follower_id  :integer
#  following_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

describe UserRelationship, type: :model do
  describe "schema" do
    it { should have_db_column(:follower_id) }
    it { should have_db_column(:following_id) }

    it { should have_db_index(:follower_id) }
    it { should have_db_index(:following_id) }

    it { should have_db_column(:created_at) }
    it { should have_db_column(:updated_at) }
  end

  describe "relationships" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:following).class_name("User") }
  end

  describe "validations" do
    it { should validate_presence_of(:follower) }
    it { should validate_presence_of(:following) }
    it { should validate_uniqueness_of(:follower_id).scoped_to(:following_id) }
  end
end

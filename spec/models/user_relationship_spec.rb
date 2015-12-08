require 'rails_helper'

describe UserRelationship, type: :model do
  describe "schema" do
    it { should have_db_column(:follower_id) }
    it { should have_db_column(:followed_id) }

    it { should have_db_index(:follower_id) }
    it { should have_db_index(:followed_id) }

    it { should have_db_column(:created_at) }
    it { should have_db_column(:updated_at) }
  end

  describe "relationships" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:followed).class_name("User") }
  end

  describe "validations" do
    it { should validate_presence_of(:follower) }
    it { should validate_presence_of(:followed) }
    it { should validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }
  end
end

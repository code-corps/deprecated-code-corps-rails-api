require 'rails_helper'

describe Comment, :type => :model do
  describe "schema" do
    it { should have_db_column(:body).of_type(:text) }
    it { should have_db_column(:post_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end
end

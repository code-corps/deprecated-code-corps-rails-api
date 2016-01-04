require 'rails_helper'

describe GithubRepository, type: :model do
  describe "schema" do
    it { should have_db_column(:owner_name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:repository_name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
  end

  describe "relationships" do
    it { should belong_to :project }
  end

  describe "validations" do
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:owner_name) }
    it { should validate_presence_of(:repository_name) }
  end
end

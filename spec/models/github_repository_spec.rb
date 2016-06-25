# == Schema Information
#
# Table name: github_repositories
#
#  id              :integer          not null, primary key
#  repository_name :string           not null
#  owner_name      :string           not null
#  project_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

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

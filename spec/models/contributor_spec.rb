require 'rails_helper'

describe Contributor, type: :model do
  describe "schema" do
    it { should have_db_column(:status).of_type(:string).with_options(null: false, default: "pending") }
    it { should have_db_column(:project_id).of_type(:integer) }
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:updated_at) }
    it { should have_db_column(:created_at) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
  end

  describe "validations" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end

  describe "behavior" do
    it { should define_enum_for(:status).with({ pending: "pending", collaborator: "collaborator", admin: "admin", owner: "owner" }) }
  end
end

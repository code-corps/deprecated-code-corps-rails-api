require 'rails_helper'

describe User, :type => :model do

  describe "schema" do
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:email).of_type(:string).with_options(null: false) }
    it { should have_db_column(:encrypted_password).of_type(:string).with_options(null: false) }
    it { should have_db_column(:confirmation_token).of_type(:string).with_options(limit: 128) }
    it { should have_db_column(:remember_token).of_type(:string).with_options(limit: 128, null: false) }
    it { should have_db_column(:admin).of_type(:boolean).with_options(null: false, default: false) }

    it { should have_db_index(:email) }
    it { should have_db_index(:remember_token) }
  end

  describe "relationships" do
    it { should have_many(:organization_memberships).with_foreign_key("member_id") }
    it { should have_many(:organizations).through(:organization_memberships) }
    it { should have_many(:team_memberships).with_foreign_key("member_id") }
    it { should have_many(:teams).through(:team_memberships) }
    it { should have_many(:projects) }
  end

  describe "admin state" do
    let(:user) { User.create(email: "joshdotsmith@gmail.com", username: "joshsmith", password: "password") }

    it "knows when it is an admin" do
      user.admin = true
      user.save
      expect(user.admin?).to eq true
    end
  end

end

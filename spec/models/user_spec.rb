require 'rails_helper'

describe User, :type => :model do

  describe "schema" do
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:email).of_type(:string).with_options(null: false) }
    it { should have_db_column(:encrypted_password).of_type(:string).with_options(null: false) }
    it { should have_db_column(:confirmation_token).of_type(:string).with_options(limit: 128) }
    it { should have_db_column(:remember_token).of_type(:string).with_options(limit: 128, null: false) }
    it { should have_db_column(:admin).of_type(:boolean).with_options(null: false, default: false) }
    it { should have_db_column(:twitter).of_type(:string) }
    it { should have_db_column(:website).of_type(:text) }
    it { should have_db_column(:biography).of_type(:text) }

    it { should have_db_index(:email) }
    it { should have_db_index(:remember_token) }
  end

  describe "relationships" do
    it { should have_many(:organization_memberships).with_foreign_key("member_id") }
    it { should have_many(:organizations).through(:organization_memberships) }
    it { should have_many(:team_memberships).with_foreign_key("member_id") }
    it { should have_many(:teams).through(:team_memberships) }
    it { should have_many(:projects) }
    it { should have_many(:posts) }
    it { should have_many(:comments) }
    it { should have_many(:user_skills) }
    it { should have_many(:skills).through(:user_skills) }
  end

  describe "validations" do
    describe "website" do
      it { should allow_value("www.example.com").for(:website) }
      it { should allow_value("http://www.example.com").for(:website) }
      it { should allow_value("example.com").for(:website) }
      it { should allow_value("www.example.museum").for(:website) }
      it { should allow_value("www.example.com#fragment").for(:website) }
      it { should allow_value("www.example.com/subdomain").for(:website) }
      it { should allow_value("api.subdomain.example.com").for(:website) }
      it { should allow_value("www.example.com?par=value").for(:website) }
      it { should allow_value("www.example.com?par1=value&par2=value").for(:website) }
      it { should_not allow_value("spaces in url").for(:website) }
      it { should_not allow_value("singleword").for(:website) }
    end

    describe "username" do
      let(:user) { User.create(email: "joshdotsmith@gmail.com", username: "joshsmith", password: "password") }
      
      it { should allow_value("code_corps").for(:username) }
      it { should allow_value("codecorps").for(:username) }
      it { should allow_value("codecorps12345").for(:username) }
      it { should allow_value("code12345corps").for(:username) }
      it { should allow_value("code____corps").for(:username) }
      it { should allow_value("code-corps").for(:username) }
      it { should allow_value("code-corps-corps").for(:username) }
      it { should allow_value("code_corps_corps").for(:username) }
      it { should allow_value("c").for(:username) }
      it { should_not allow_value("-codecorps").for(:username) }
      it { should_not allow_value("codecorps-").for(:username) }
      it { should_not allow_value("@codecorps").for(:username) }
      it { should_not allow_value("code----corps").for(:username) }
      it { should_not allow_value("code/corps").for(:username) }
      it { should_not allow_value("code_corps/code_corps").for(:username) }
      it { should_not allow_value("code///corps").for(:username) }
      it { should_not allow_value("@code/corps/code").for(:username) }
      it { should_not allow_value("@code/corps/code/corps").for(:username) }
      it { expect(user.username).to_not be_profane }
    end
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

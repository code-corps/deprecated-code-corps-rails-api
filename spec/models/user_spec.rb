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
    it { should have_db_column(:facebook_id).of_type(:string) }
    it { should have_db_column(:facebook_access_token).of_type(:string) }

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

    it { should have_many(:active_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:passive_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:followed).through(:active_relationships).source(:following) }
    it { should have_many(:followers).through(:passive_relationships).source(:follower) }
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
      describe "base validations" do
        # visit the following to understand why this is tested in a separate context
        # https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb#L50
        subject { create(:user) }
        it { should validate_presence_of(:username) }
        it { should validate_uniqueness_of(:username).case_insensitive }
        it { should validate_length_of(:username).is_at_most(39) }
      end

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

      # Checks reserved routes
      it { should_not allow_value("help").for(:username) }

      describe "duplicate slug validation" do
        context "when an organization with a different cased slug exists" do
          before do
            create(:organization, name: "CodeCorps")
          end

          it { should_not allow_value("codecorps").for(:username).with_message(
            "has already been taken by an organization"
            ) }
        end

        context "when an organization with the same slug exists" do
          before do
            create(:organization, name: "CodeCorps")
          end

          it { should_not allow_value("codecorps").for(:username).with_message(
            "has already been taken by an organization"
            ) }
        end
      end

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

  describe "updating the username" do
    let(:user) { create(:user, username: "joshsmith") }

    it "should allow the username to be updated" do
      user.username = "new_name"
      user.save

      expect(user.username).to eq "new_name"
    end
  end

end

require "rails_helper"
require_relative "../utils"

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
    it { should have_db_column(:photo_file_name).of_type(:string) }
    it { should have_db_column(:photo_content_type).of_type(:string) }
    it { should have_db_column(:photo_file_size).of_type(:integer) }
    it { should have_db_column(:photo_updated_at).of_type(:datetime) }

    it { should have_db_index(:email) }
    it { should have_db_index(:remember_token) }
  end

  describe "relationships" do
    it { should have_many(:organization_memberships).with_foreign_key("member_id") }
    it { should have_many(:organizations).through(:organization_memberships) }
    it { should have_many(:team_memberships).with_foreign_key("member_id") }
    it { should have_many(:teams).through(:team_memberships) }
    it { should have_many(:posts) }
    it { should have_many(:comments) }
    it { should have_many(:user_skills) }
    it { should have_many(:skills).through(:user_skills) }
    it { should have_many(:active_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:passive_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:following).through(:active_relationships).source(:following) }
    it { should have_many(:followers).through(:passive_relationships).source(:follower) }
    it { should have_one(:member) }

    it { should have_many(:contributors) }
    it { should have_many(:projects).through(:contributors) }
  end

  describe "validations" do
    context "paperclip",
            vcr: { cassette_name: "models/user/validation" },
            skip: S3_ENABLED do
      it { should validate_attachment_size(:photo).less_than(10.megabytes) }
    end


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
      it { expect(user.username).to_not be_profane }

      # Checks reserved routes
      it { should_not allow_value("help").for(:username) }

      describe "duplicate slug validation" do
        context "when an organization with a different cased slug exists" do
          before do
            create(:organization, name: "CodeCorps")
          end

          it {
            should_not allow_value("codecorps").for(:username).with_message(
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

  context "paperclip" do
    context "without cloudfront" do
      it { should have_attached_file(:photo) }
      it { should validate_attachment_content_type(:photo).
        allowing("image/png", "image/gif", "image/jpeg").
        rejecting("text/plain", "text/xml")
      }
    end

    context "with cloudfront", skip: CLOUDFRONT_ENABLED do
      let(:user) { create(:user, :with_s3_photo) }

      it "should have our cloudfront domain in the URL" do
        expect(user.photo.url(:thumb)).to include ENV["CLOUDFRONT_DOMAIN"]
      end

      it "should have the right path" do
        expect(user.photo.url(:thumb)).to include "users/#{user.id}/thumb"
      end
    end
  end

  context "following behavior" do
    before(:each) do
      @user = create(:user)
      @other_user_1 = create(:user)
      @other_user_2 = create(:user)
    end

    it "can have followers" do
      create(:user_relationship, follower: @other_user_1, following: @user)
      create(:user_relationship, follower: @other_user_2, following: @user)

      expect(@user.followers.length).to eq 2
    end

    it "can have other users it follows" do
      create(:user_relationship, follower: @user, following: @other_user_1)
      create(:user_relationship, follower: @user, following: @other_user_2)

      expect(@user.following.length).to eq 2
    end

    it "can follow another user" do
      @user.follow(@other_user_1)
      expect(@user.following? @other_user_1).to be true
    end

    it "can unfollow another user" do
      create(:user_relationship, follower: @user, following: @other_user_1)
      @user.unfollow(@other_user_1)
      expect(@user.following? @other_user_1).to be false
    end
  end
end

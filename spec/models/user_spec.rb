# == Schema Information
#
# Table name: users
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  username              :string
#  admin                 :boolean          default(FALSE), not null
#  website               :text
#  twitter               :string
#  biography             :text
#  facebook_id           :string
#  facebook_access_token :string
#  base64_photo_data     :string
#  photo_file_name       :string
#  photo_content_type    :string
#  photo_file_size       :integer
#  photo_updated_at      :datetime
#  aasm_state            :string           default("signed_up"), not null
#  theme                 :string           default("light"), not null
#  first_name            :string
#  last_name             :string
#

require "rails_helper"

describe User, type: :model do
  describe "schema" do
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:email).of_type(:string).with_options(null: false) }
    it { should have_db_column(:encrypted_password).of_type(:string).with_options(null: false) }
    it { should have_db_column(:confirmation_token).of_type(:string).with_options(limit: 128) }
    it { should have_db_column(:remember_token).of_type(:string).with_options(limit: 128, null: false) }
    it { should have_db_column(:admin).of_type(:boolean).with_options(null: false, default: false) }
    it { should have_db_column(:twitter).of_type(:string) }
    it { should have_db_column(:first_name).of_type(:text) }
    it { should have_db_column(:last_name).of_type(:text) }
    it { should have_db_column(:website).of_type(:text) }
    it { should have_db_column(:biography).of_type(:text) }
    it { should have_db_column(:facebook_id).of_type(:string) }
    it { should have_db_column(:facebook_access_token).of_type(:string) }
    it { should have_db_column(:photo_file_name).of_type(:string) }
    it { should have_db_column(:photo_content_type).of_type(:string) }
    it { should have_db_column(:photo_file_size).of_type(:integer) }
    it { should have_db_column(:photo_updated_at).of_type(:datetime) }
    it { should have_db_column(:aasm_state).of_type(:string).with_options(default: "signed_up", null: false) }
    it { should have_db_column(:theme).of_type(:string).with_options(default: "light", null: false) }
    it { should have_db_column(:first_name).of_type(:string) }
    it { should have_db_column(:last_name).of_type(:string) }

    it { should have_db_index(:email) }
    it { should have_db_index(:remember_token) }
  end

  describe "relationships" do
    it { should have_many(:organization_memberships).with_foreign_key("member_id") }
    it { should have_many(:organizations).through(:organization_memberships) }
    it { should have_many(:posts) }
    it { should have_many(:comments) }
    it { should have_many(:user_skills) }
    it { should have_many(:skills).through(:user_skills) }
    it { should have_many(:user_roles) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_many(:user_categories) }
    it { should have_many(:categories).through(:user_categories) }
    it { should have_many(:active_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:passive_relationships).class_name("UserRelationship").dependent(:destroy) }
    it { should have_many(:following).through(:active_relationships).source(:following) }
    it { should have_many(:followers).through(:passive_relationships).source(:follower) }
    it { should have_one(:slugged_route) }
  end

  describe "validations" do
    context "paperclip", vcr: { cassette_name: "models/user/validation" } do
      it { should validate_attachment_size(:photo).less_than(10.megabytes) }
    end

    describe "password" do
      context "on create" do
        subject { build(:user) }
        it do
          should validate_length_of(:password).is_at_least(6).with_message(
            "must be at least 6 characters"
          )
        end
      end

      context "on update" do
        context "when password is present" do
          subject { create(:user) }
          it do
            should validate_length_of(:password).is_at_least(6).with_message(
              "must be at least 6 characters"
            )
          end
        end

        context "when password is not present" do
          it "updates without validation errors" do
            user = create(:user)
            user.username = "new_username"
            user.save
            user.reload

            expect(user.username).to eq "new_username"
          end
        end
      end
    end

    describe "website" do
      user = User.new(
        email: "joshdotsmith@gmail.com",
        username: "joshsmith",
        password: "password",
        website: "www.codecorps.com"
      )

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
      it do
        expect { user.save }.
          to change { user.website }.
          from("www.codecorps.com").
          to("http://www.codecorps.com")
      end
    end

    describe "name" do
      let(:user) { User.create(first_name: "Josh", last_name: "Smith") }

      it "should combine the first and last name" do
        expect(user.name).to eq "Josh Smith"
      end
    end

    describe "username" do
      let(:user) do
        User.create(email: "joshdotsmith@gmail.com", username: "joshsmith", password: "password")
      end

      describe "base validations" do
        # visit the following to understand why this is tested in a separate context
        # https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb#L50
        subject { create(:user) }
        it { should validate_presence_of(:username) }
        it { should validate_uniqueness_of(:username).case_insensitive }
        it { should validate_length_of(:username).is_at_most(39) }
      end

      it_behaves_like "a slug validating model", :username

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

      describe "twitter username validation" do
        context "when username has an '@' symbol" do
          it "returns an error" do
            should_not allow_value("@codecorps").for(:twitter).with_message(
              "contains an invalid character"
            )
          end
        end
      end
    end
  end

  describe "behavior" do
    it { should define_enum_for(:theme).with(light: "light", dark: "dark") }
  end

  describe "strip_attributes" do
    it { is_expected.to strip_attribute(:biography) }
    it { is_expected.to strip_attribute(:twitter) }
    it { is_expected.to strip_attribute(:website) }
  end

  describe ".email_taken?" do
    context "when available" do
      it "works" do
        expect(User.email_taken?("josh@codecorps.org")).to eq false
      end
    end

    context "when taken" do
      it "works case-insensitive" do
        create(:user, email: "JOSH@CODECORPS.ORG")
        expect(User.email_taken?("josh@codecorps.org")).to eq true
      end
    end
  end

  describe ".username_taken?" do
    context "when available" do
      it "works" do
        expect(User.username_taken?("joshsmith")).to eq false
      end
    end

    context "when taken" do
      it "works case-insensitive" do
        create(:user, username: "JOSHSMITH")
        expect(User.username_taken?("joshsmith")).to eq true
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

  describe "onboarding" do
    let(:user) { create(:user) }

    it "transitions correctly when state_transition is set and saved" do
      expect(user).to have_state(:signed_up)

      expect_any_instance_of(Analytics).to receive(:track_edited_profile)
      user.state_transition = "edit_profile"
      user.save

      expect(user).to have_state(:edited_profile)

      expect_any_instance_of(Analytics).to receive(:track_selected_categories)
      user.state_transition = "select_categories"
      user.save

      expect(user).to have_state(:selected_categories)

      expect_any_instance_of(Analytics).to receive(:track_selected_roles)
      user.state_transition = "select_roles"
      user.save

      expect(user).to have_state(:selected_roles)

      expect_any_instance_of(Analytics).to receive(:track_selected_skills)
      user.state_transition = "select_skills"
      user.save

      expect(user).to have_state(:selected_skills)
    end
  end

  describe "name" do
    it "returns the full name" do
      user = create(:user, first_name: "Frank", last_name: "Reynolds")

      full_name = "Frank Reynolds"

      expect(user.name).to eq full_name
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

    context "with cloudfront", local_skip: true do
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

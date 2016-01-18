# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  title              :string           not null
#  description        :string
#  owner_id           :integer
#  owner_type         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  icon_file_name     :string
#  icon_content_type  :string
#  icon_file_size     :integer
#  icon_updated_at    :datetime
#  base64_icon_data   :text
#  contributors_count :integer
#  slug               :string           not null
#

require "rails_helper"

describe Project, :type => :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:icon_file_name).of_type(:string) }
    it { should have_db_column(:icon_content_type).of_type(:string) }
    it { should have_db_column(:icon_file_size).of_type(:integer) }
    it { should have_db_column(:icon_updated_at).of_type(:datetime) }
    it { should have_db_column(:contributors_count).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:owner) }
    it { should have_many(:posts) }
    it { should have_many(:github_repositories) }
    it { should have_many(:contributors) }
    it { should have_many(:users).through(:contributors) }
  end

  describe "validations" do

    context "paperclip", vcr: { cassette_name: "models/project/validation" } do
      it { should validate_attachment_size(:icon).less_than(10.megabytes) }
    end

    describe "title" do
      describe "base validations" do
        # visit the following to understand why this is tested in a separate context
        # https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb#L50
        subject { create(:project) }
        it { should validate_presence_of(:title) }
      end

      it { should allow_value("code_corps").for(:slug) }
      it { should allow_value("codecorps").for(:slug) }
      it { should allow_value("codecorps12345").for(:slug) }
      it { should allow_value("code12345corps").for(:slug) }
      it { should allow_value("code____corps").for(:slug) }
      it { should allow_value("code-corps").for(:slug) }
      it { should allow_value("code-corps-corps").for(:slug) }
      it { should allow_value("code_corps_corps").for(:slug) }
      it { should allow_value("c").for(:slug) }
      it { should_not allow_value("-codecorps").for(:slug) }
      it { should_not allow_value("codecorps-").for(:slug) }
      it { should_not allow_value("@codecorps").for(:slug) }
      it { should_not allow_value("code----corps").for(:slug) }
      it { should_not allow_value("code/corps").for(:slug) }
      it { should_not allow_value("code_corps/code_corps").for(:slug) }
      it { should_not allow_value("code///corps").for(:slug) }
      it { should_not allow_value("@code/corps/code").for(:slug) }
      it { should_not allow_value("@code/corps/code/corps").for(:slug) }
    end

    describe "duplicate slug validation" do
      context "when an project with a different cased slug exists" do
        before do
          @organization = create(:organization)
          create(:project, owner: @organization, title: "CodeCorps")
        end

        it "should have the right errors" do
          project = Project.create(owner: @organization, title: "codecorps")
          expect(project.errors.messages.count).to eq 1
          expect(project.errors.messages[:slug].first).to eq "has already been taken"
        end
      end

      context "when a project with the same slug exists" do
        before do
          @organization = create(:organization)
          create(:project, owner: @organization, title: "CodeCorps")
        end

        it "should have the right errors" do
          project = Project.create(owner: @organization, title: "CodeCorps")
          expect(project.errors.messages.count).to eq 1
          expect(project.errors.messages[:slug].first).to eq "has already been taken"
        end
      end
    end
  end

  describe "ownership" do
    it { should validate_presence_of :owner }

    it "can have a user as an owner" do
      user = create(:user)
      project = create(:project, owner: user)
      project.reload
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_a User
      expect(project.owner_type).to eq "User"
    end

    it "can have an organization as an owner" do
      organization = create(:organization)
      project = create(:project, owner: organization)
      project.reload
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_an Organization
      expect(project.owner_type).to eq "Organization"
    end
  end

  context "paperclip" do
    context "without cloudfront" do
      it { should have_attached_file(:icon) }
      it { should validate_attachment_content_type(:icon).
        allowing("image/png", "image/gif", "image/jpeg").
        rejecting("text/plain", "text/xml")
      }
    end

    context "with cloudfront" do

      let(:project) { create(:project, :with_s3_icon) }

      it "should have our cloudfront domain in the URL" do
        expect(project.icon.url(:thumb)).to include ENV["CLOUDFRONT_DOMAIN"]
      end

      it "should have the right path" do
        expect(project.icon.url(:thumb)).to include "projects/#{project.id}/thumb"
      end
    end
  end

end


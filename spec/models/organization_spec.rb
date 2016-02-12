# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string           not null
#

require "rails_helper"

describe Organization, :type => :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { should have_db_column(:icon_file_name).of_type(:string) }
    it { should have_db_column(:icon_content_type).of_type(:string) }
    it { should have_db_column(:icon_file_size).of_type(:integer) }
    it { should have_db_column(:icon_updated_at).of_type(:datetime) }
  end

  describe "relationships" do
    it { should have_many(:members).through(:organization_memberships) }
    it { should have_many(:projects) }
    it { should have_one(:slugged_route) }
  end

  describe "validations" do

    context "paperclip", vcr: { cassette_name: "models/organization/validation" } do
      it { should validate_attachment_size(:icon).less_than(10.megabytes) }
    end

    it { should validate_presence_of(:slug) }

    describe "name" do

      describe "base validations" do
        # visit the following to understand why this is tested in a separate context
        # https://github.com/thoughtbot/shoulda-matchers/blob/master/lib/shoulda/matchers/active_record/validate_uniqueness_of_matcher.rb#L50
        subject { create(:organization) }
        it { should validate_presence_of(:name) }
        it { should validate_uniqueness_of(:slug).case_insensitive }
        it { should validate_length_of(:slug).is_at_most(39) }
      end

      let(:organization) { Organization.create(name: "Test") }

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
      it { expect(organization.slug).to_not be_profane }

      # Checks reserved routes
      it { should_not allow_value("help").for(:slug) }

      describe "duplicate slug validation" do
        context "when a user with a different cased slug exists" do
          before do
            create(:user, username: "CodeCorps")
          end

          it { should_not allow_value("codecorps").for(:slug).with_message(
            "has already been taken by a user"
            ) }
        end

        context "when a user with the same slug exists" do
          before do
            create(:user, username: "codecorps")
          end

          it { should_not allow_value("codecorps").for(:slug).with_message(
            "has already been taken by a user"
            ) }
        end
      end
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

  describe "instance methods" do
    describe "#admins" do
      it "should return users with membership role 'admin'" do
        organization = create(:organization)
        create_list(:organization_membership, 10, role: "admin", organization: organization)
        create_list(:organization_membership, 10, role: "contributor", organization: organization)

        organization.reload

        expect(organization.admins.length).to eq 10
        expect(organization.members.length).to eq 20

        expect(organization.admins.all? { |admin| admin.class == User }).to be true
      end
    end
  end

  describe "slug" do
    it "should be auto-set from name" do
      create(:organization, name: "Sluggable Organization")
      expect(Organization.last.slug).to eq "sluggable-organization"
    end
  end
end

# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#  slug              :string           not null
#  organization_id   :integer          not null
#  aasm_state        :string
#

require "rails_helper"

describe Project, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:long_description_body).of_type(:text) }
    it { should have_db_column(:long_description_markdown).of_type(:text) }
    it { should have_db_column(:icon_file_name).of_type(:string) }
    it { should have_db_column(:icon_content_type).of_type(:string) }
    it { should have_db_column(:icon_file_size).of_type(:integer) }
    it { should have_db_column(:icon_updated_at).of_type(:datetime) }
  end

  describe "relationships" do
    it { should belong_to(:organization) }
    it { should have_many(:project_categories) }
    it { should have_many(:categories).through(:project_categories) }
    it { should have_many(:project_roles) }
    it { should have_many(:roles).through(:project_roles) }
    it { should have_many(:project_skills) }
    it { should have_many(:skills).through(:project_skills) }
    it { should have_many(:github_repositories) }
    it { should have_many(:posts) }
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
    end

    it_behaves_like "a slug validating model", :slug

    describe "duplicate slug validation" do
      context "when an project with a different cased slug exists" do
        before do
          @organization = create(:organization)
          create(:project, organization: @organization, title: "CodeCorps")
        end

        it "should have the right errors" do
          project = Project.create(organization: @organization, title: "codecorps")
          expect(project.errors.messages.count).to eq 1
          expect(project.errors.messages[:slug].first).to eq "has already been taken"
        end
      end

      context "when a project with the same slug exists" do
        before do
          @organization = create(:organization)
          create(:project, organization: @organization, title: "CodeCorps")
        end

        it "should have the right errors" do
          project = Project.create(organization: @organization, title: "CodeCorps")
          expect(project.errors.messages.count).to eq 1
          expect(project.errors.messages[:slug].first).to eq "has already been taken"
        end
      end
    end
  end

  describe "ownership" do
    it { should validate_presence_of :organization }
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

  describe "#save" do
    context "when markdown is not empty" do
      it "renders markdown to body" do
        post = build(:project, long_description_markdown: "# Hello World\n\nHello, world.")
        post.save
        expect(post.long_description_body).to eq "<h1>Hello World</h1>\n\n<p>Hello, world.</p>"
      end
    end

    context "when markdown is empty" do
      it "does not render markdown to body" do
        post = build(:project, long_description_markdown: "")
        post.save
        expect(post.long_description_body).to be_nil
      end
    end
  end
end

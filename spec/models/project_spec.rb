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
#

require "rails_helper"

describe Project, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:icon_file_name).of_type(:string) }
    it { should have_db_column(:icon_content_type).of_type(:string) }
    it { should have_db_column(:icon_file_size).of_type(:integer) }
    it { should have_db_column(:icon_updated_at).of_type(:datetime) }
    it { should have_db_column(:aasm_state).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:organization) }
    it { should have_many(:project_categories) }
    it { should have_many(:categories).through(:project_categories) }
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

  describe "state machine" do
    let(:project) { Project.new }

    it "sets the state to created initially" do
      expect(project).to have_state(:created)
    end

    context "when project is missing details" do
      it "does not transition" do
        expect { project.publish }.to raise_error(AASM::InvalidTransition)
      end
    end

    context "when project has details" do
      let(:project) do
        create(:project,
               title: "Title",
               description: "Description",
               categories: [create(:category)])
      end

      it "transitions correctly" do
        expect(project).to transition_from(:created).to(:published).on_event(:publish)
      end
    end
  end

  describe "#update" do
    context "when not publishing" do
      it "just saves a published project" do
        project = create(:project, :with_categories)
        project.publish
        expect(project.update(false)).to be true

        expect(project.published?).to be true
      end
    end

    context "when publishing" do
      context "without required information" do
        it "does not publish the project" do
          project = create(:project)
          expect(project.update(true)).to be false

          expect(project.published?).to be false
        end
      end

      context "with required information" do
        it "publishes a project" do
          project = create(:project, :with_categories)
          expect(project.update(true)).to be true

          expect(project.published?).to be true
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
end

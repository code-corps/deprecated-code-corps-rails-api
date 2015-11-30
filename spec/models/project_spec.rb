require 'rails_helper'

describe Project, :type => :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:icon_file_name).of_type(:string) }
    it { should have_db_column(:icon_content_type).of_type(:string) }
    it { should have_db_column(:icon_file_size).of_type(:integer) }
    it { should have_db_column(:icon_updated_at).of_type(:datetime) }
  end

  describe "relationships" do
    it { should belong_to(:owner) }
    it { should have_many(:posts) }
  end

  describe "ownership" do
    it "can have a user as an owner" do
      user = create(:user)
      project = create(:project, owner: user)
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_a User
      expect(project.owner_type).to eq "User"
    end

    it "can have an organization as an owner" do
      organization = create(:organization)
      project = create(:project, owner: organization)
      expect(project).to be_persisted
      expect(project).to be_valid
      expect(project.owner).to be_an Organization
      expect(project.owner_type).to eq "Organization"
    end
  end

  context 'paperclip' do
    context 'without cloudfront' do
      it { should have_attached_file(:icon) }
      it { should validate_attachment_content_type(:icon)
          .allowing('image/png', 'image/gif', 'image/jpeg')
          .rejecting('text/plain', 'text/xml') }
    end

    context 'with cloudfront' do

      let(:project) { create(:project, :with_s3_icon) }

      it 'should have cloudfront in the URL' do
        expect(project.icon.url(:thumb)).to include 'cloudfront'
      end

      it 'should have the right path' do
        expect(project.icon.url(:thumb)).to include "projects/#{project.id}/thumb"
      end
    end
  end

end


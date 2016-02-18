# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string           not null
#  icon_file_name    :string
#  icon_content_type :string
#  icon_file_size    :integer
#  icon_updated_at   :datetime
#  base64_icon_data  :text
#

require "rails_helper"

describe OrganizationSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) do
      organization = create(:organization)
      create_list(:project, 10, organization: organization)
      create(:organization_membership, member: create(:user), organization: organization)
      organization
    end

    let(:serializer) { OrganizationSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be nil
      end

      it "has a type set to 'organizations'" do
        expect(subject["type"]).to eq "organizations"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'name'" do
        expect(subject["name"]).to_not be_nil
        expect(subject["name"]).to eql resource.name
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to_not be_nil
        expect(subject["slug"]).to eql resource.slug
      end

      it "has a 'description'" do
        expect(subject["description"]).to_not be_nil
        expect(subject["description"]).to eql resource.description
      end

      it "has a 'icon_thumb_url'" do
        expect(subject["icon_thumb_url"]).to_not be_nil
        expect(subject["icon_thumb_url"]).to eql resource.icon.url(:thumb)
      end

      it "has a 'icon_large_url'" do
        expect(subject["icon_large_url"]).to_not be_nil
        expect(subject["icon_large_url"]).to eql resource.icon.url(:large)
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should have a 'projects' relationship" do
        expect(subject["projects"]).not_to be_nil
        expect(subject["projects"]["data"].length).to eq 10
        expect(subject["projects"]["data"].all? { |r| r["type"] == "projects" }).to be true
      end

      it "should have a 'members' relationship" do
        expect(subject["members"]).not_to be_nil
        expect(subject["members"]["data"].length).to eq 1
        expect(subject["members"]["data"].all? { |r| r["type"] == "users" }).to be true
      end
    end

    context "included" do
      context "when not including anything" do
        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should be empty" do
          expect(subject).to be_nil
        end
      end
    end
  end
end

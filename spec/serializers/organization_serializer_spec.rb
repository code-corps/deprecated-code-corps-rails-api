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

describe OrganizationSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:organization) }

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
        expect(subject["name"]).to eql resource.name
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to eql resource.slug
      end

      it "has 'icon url's" do
        expect(subject["icon_thumb_url"]).to eql resource.icon(:thumb)
        expect(subject["icon_large_url"]).to eql resource.icon(:large)
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
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

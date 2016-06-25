# == Schema Information
#
# Table name: slugged_routes
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe SluggedRouteSerializer, type: :serializer do

  context "individual resource representation" do
    # Due to the fact slugged_route records are automatically created upon saving
    # a user or an organization, this is the "correct" way to get a working
    # slugged_route instance.
    # If we try to define a factory which has an association, then we will be gettin unique
    # constraint violations, due to a slugged_route record with the same owner_type and owner_id being
    # created automatically.
    let(:resource) { create(:organization).slugged_route }

    let(:serializer) { SluggedRouteSerializer.new(resource) }
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

      it "has a type set to 'slugged_routes'" do
        expect(subject["type"]).to eq "slugged_routes"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to_not be_nil
        expect(subject["slug"]).to eql resource.slug
      end

      it "has an 'owner_type'" do
        expect(subject["owner_type"]).to_not be_nil
        expect(subject["owner_type"]).to eql resource.owner_type
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include 'owner'" do
        expect(subject["owner"]).not_to be_nil
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

      context "when including owner" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["owner"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the slugged_routes's owner" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "organizations"}.length).to eq 1
        end
      end
    end
  end
end

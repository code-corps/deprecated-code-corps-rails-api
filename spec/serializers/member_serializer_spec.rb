# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  model_id   :integer
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe MemberSerializer, :type => :serializer do

  context "individual resource representation" do
    # Due to the fact member records are automatically created upon saving
    # a user or an organization, this is the "correct" way to get a working
    # member instance.
    # If we try to define a factory which has an association, then we will be gettin unique
    # constraint violations, due to a member record with the same model_type and model_id being
    # created automatically.
    let(:resource) { create(:organization).member }

    let(:serializer) { MemberSerializer.new(resource) }
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

      it "has a type set to 'members'" do
        expect(subject["type"]).to eq "members"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to eql resource.slug
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include 'model'" do
        expect(subject["model"]).not_to be_nil
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

      context "when including model" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["model"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the members's model" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "organizations"}.length).to eq 1
        end
      end
    end
  end
end

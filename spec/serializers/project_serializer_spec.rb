require "rails_helper"

describe ProjectSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:project, :with_contributors, contributors_count: 5) }

    let(:serializer) { ProjectSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'projects'" do
        expect(subject["type"]).to eq "projects"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'title'" do
        expect(subject["title"]).to eql resource.title
      end

      it "has a 'description'" do
        expect(subject["description"]).to eql resource.description
      end

      it "has a 'contributors_count'" do
        expect(subject["contributors_count"]).to eql resource.contributors_count
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'contributors' relationship" do
        expect(subject["contributors"]).not_to be_nil
        expect(subject["contributors"]["data"].count).to eq 5
      end
    end

    context "included" do
      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should be empty" do
        expect(subject).to be_nil
      end
    end
  end
end

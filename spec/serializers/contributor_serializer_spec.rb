require "rails_helper"

describe ContributorSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      create(:contributor)
    }

    let(:serializer) { ContributorSerializer.new(resource) }
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

      it "has a type set to 'contributors'" do
        expect(subject["type"]).to eq "contributors"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'status'" do
        expect(subject["status"]).to eql resource.status
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include 'project'" do
        expect(subject["project"]).not_to be_nil
      end

      it "should include 'user'" do
        expect(subject["user"]).not_to be_nil
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

      context "when including 'project'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["project"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "projects"}.length).to eq 1
        end
      end

      context "when including 'user'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["user"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "users"}.length).to eq 1
        end
      end
    end
  end
end

require "rails_helper"

describe CommentSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      create(:comment, body: "Comment body", post: create(:post))
    }

    let(:serializer) { CommentSerializer.new(resource) }
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

      it "has a type set to 'projects'" do
        expect(subject["type"]).to eq "comments"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'body'" do
        expect(subject["body"]).to eql resource.body
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include 'post'" do
        expect(subject["post"]).not_to be_nil
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
    end
  end
end

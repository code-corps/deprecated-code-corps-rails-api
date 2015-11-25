require "rails_helper"

describe PostSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      post = create(:post,
        title: "Post title")

      create_list(:comment, 10, post: post)
      post.reload
    }

    let(:serializer) { PostSerializer.new(resource) }
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
        expect(subject["type"]).to eq "posts"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'title'" do
        expect(subject["title"]).to eql resource.title
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should include 'comments'" do
        expect(subject["comments"]).not_to be_nil
        expect(subject["comments"]["data"].length).to eq 10
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

      context "when including 'comments'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["comments"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "comments"}.length).to eq 10
        end
      end
    end
  end
end

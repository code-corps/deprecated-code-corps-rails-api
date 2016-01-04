require "rails_helper"

describe PostSerializerWithoutIncludes, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      post = create(:post,
        title: "Post title",
        user: create(:user),
        project: create(:project))

      create_list(:comment, 10, post: post)
      post.reload
    }

    let(:serializer) { PostSerializerWithoutIncludes.new(resource) }
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

      it "has a type set to 'posts'" do
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

      it "has a 'status'" do
        expect(subject["status"]).to eql resource.status
      end

      it "has a 'post_type'" do
        expect(subject["post_type"]).to eql resource.post_type
      end

      it "has a 'likes_count'" do
        expect(subject["likes_count"]).to eql resource.likes_count
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should be nil" do
        expect(subject).to be_nil
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

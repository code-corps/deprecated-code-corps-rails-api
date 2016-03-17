require "rails_helper"

describe PostSerializerWithoutIncludes, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      post = create(:post,
        title: "Post title",
        user: create(:user),
        project: create(:project),
        body: "Some body",
        number: 1)

      post.publish!
      post.edit!

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

      it "has a 'body'" do
        expect(subject["body"]).not_to be_nil
        expect(subject["body"]).to eql resource.body
      end

      it "has 'markdown'" do
        expect(subject["markdown"]).not_to be_nil
        expect(subject["markdown"]).to eql resource.markdown
      end

      it "has a 'body_preview'" do
        expect(subject["body_preview"]).not_to be_nil
        expect(subject["body_preview"]).to eql resource.body_preview
      end

      it "has 'markdown_preview'" do
        expect(subject["markdown_preview"]).not_to be_nil
        expect(subject["markdown_preview"]).to eql resource.markdown_preview
      end

      it "has a 'status'" do
        expect(subject["status"]).to_not be_nil
        expect(subject["status"]).to eql resource.status
      end

      it "has a 'number'" do
        expect(subject["number"]).to_not be_nil
        expect(subject["number"]).to eql resource.number
      end

      it "has a 'post_type'" do
        expect(subject["post_type"]).to_not be_nil
        expect(subject["post_type"]).to eql resource.post_type
      end

      it "has a 'likes_count'" do
        expect(subject["likes_count"]).to_not be_nil
        expect(subject["likes_count"]).to eql resource.post_likes_count
      end

      it "has a 'state'" do
        expect(subject["state"]).to eql resource.state
      end

      it "has an 'edited_at'" do
        expect(subject["edited_at"]).to be_the_same_time_as resource.edited_at
      end

      it "has a 'comments_count'" do
        expect(subject["comments_count"]).to eql resource.comments_count
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

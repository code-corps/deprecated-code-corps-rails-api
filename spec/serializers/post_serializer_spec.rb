require "rails_helper"

describe PostSerializer, :type => :serializer do

  # We only use before all here because we know the context does not change
  before :all do
    @post = create(:post,
      title: "Post title",
      user: create(:user),
      project: create(:project))

    create_list(:comment, 10, post: @post)
    create_list(:post_user_mention, 10, post: @post)
    create_list(:comment_user_mention, 10, post: @post)
    @post.reload
  end

  context "individual resource representation" do

    let(:resource) { @post }

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
        expect(subject["body"]).to eql resource.body
      end

      it "has 'markdown'" do
        expect(subject["markdown"]).to eql resource.markdown
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

      it "has a 'number'" do
        expect(subject["number"]).to eql resource.number
      end

      it "has a 'state'" do
        expect(subject["state"]).to eql resource.state
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

      it "should include 'user'" do
        expect(subject["user"]).not_to be_nil
      end

      it "should include 'project'" do
        expect(subject["project"]).not_to be_nil
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

      context "when including 'post_user_mentions'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["post_user_mentions"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "post_user_mentions"}.length).to eq 10
        end
      end

      context "when including 'comment_user_mentions'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["comment_user_mentions"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "comment_user_mentions"}.length).to eq 10
        end
      end
    end
  end
end

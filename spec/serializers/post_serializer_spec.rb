# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  status           :string           default("open")
#  post_type        :string           default("task")
#  title            :string
#  body             :text
#  user_id          :integer          not null
#  project_id       :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  post_likes_count :integer          default(0)
#  markdown         :text
#  number           :integer
#  aasm_state       :string
#  comments_count   :integer          default(0)
#  body_preview     :text
#  markdown_preview :text
#

require "rails_helper"

describe PostSerializer, :type => :serializer do

  # We only use before all here because we know the context does not change
  before :all do
    @post = create(:post,
      title: "Post title",
      user: create(:user),
      project: create(:project),
      number: 1)

    @post.publish!
    @post.edit!

    create_list(:comment, 2, post: @post)
    create_list(:post_user_mention, 2, post: @post)
    create_list(:comment_user_mention, 2, post: @post)

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
        expect(subject["number"]).to_not be_nil
        expect(subject["number"]).to eql resource.number
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

      it "should include 'comments'" do
        expect(subject["comments"]).not_to be_nil
        expect(subject["comments"]["data"].length).to eq 2
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
          expect(subject.select{ |i| i["type"] == "comments"}.length).to eq 2
        end
      end

      context "when including 'post_user_mentions'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["post_user_mentions"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "post_user_mentions"}.length).to eq 2
        end
      end

      context "when including 'comment_user_mentions'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["comment_user_mentions"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "comment_user_mentions"}.length).to eq 2
        end
      end
    end
  end
end

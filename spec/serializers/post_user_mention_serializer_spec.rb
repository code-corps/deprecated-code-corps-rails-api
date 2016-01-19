# == Schema Information
#
# Table name: post_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

describe PostUserMentionSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:post_user_mention) }

    let(:serializer) { PostUserMentionSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'post_user_mentions'" do
        expect(subject["type"]).to eq "post_user_mentions"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'username'" do
        expect(subject["username"]).to eql resource.user.username
      end

      it "has 'indices'" do
        expect(subject["indices"]).to eql resource.indices
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'user' relationship" do
        expect(subject["user"]).not_to be_nil
        expect(subject["user"]["data"]["type"]).to eq "users"
        expect(subject["user"]["data"]["id"]).to eq resource.user.id.to_s
      end

      it "should contain a 'post' relationship without comments" do
        expect(subject["post"]).not_to be_nil
        expect(subject["post"]["data"]["type"]).to eq "posts"
        expect(subject["post"]["data"]["id"]).to eq resource.post.id.to_s
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

      context "when including 'post'" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["post"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "posts"}.length).to eq 1
        end
      end
    end
  end
end

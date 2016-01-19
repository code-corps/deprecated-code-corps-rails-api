# == Schema Information
#
# Table name: post_likes
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe PostLikeSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) { create(:post_like) }

    let(:serializer) { PostLikeSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "doesn't have an attributes object" do
        expect(subject["attributes"]).to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'post_likes'" do
        expect(subject["type"]).to eq "post_likes"
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

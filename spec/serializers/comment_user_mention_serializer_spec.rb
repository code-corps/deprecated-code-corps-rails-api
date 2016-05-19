# == Schema Information
#
# Table name: comment_user_mentions
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  comment_id  :integer          not null
#  post_id     :integer          not null
#  username    :string           not null
#  start_index :integer          not null
#  end_index   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string           default("preview"), not null
#

require "rails_helper"

describe CommentUserMentionSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:comment_user_mention) }

    let(:serializer) { CommentUserMentionSerializer.new(resource) }
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

      it "has a type set to 'comment_user_mentions'" do
        expect(subject["type"]).to eq "comment_user_mentions"
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

      it "has 'status'" do
        expect(subject["status"]).not_to be_nil
        expect(subject["status"]).to eql resource.status
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

      it "should contain a 'comment' relationship without comments" do
        expect(subject["comment"]).not_to be_nil
        expect(subject["comment"]["data"]["type"]).to eq "comments"
        expect(subject["comment"]["data"]["id"]).to eq resource.comment.id.to_s
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
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["user"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.count { |i| i["type"] == "users" }).to eq 1
        end
      end

      context "when including 'comment'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["comment"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.count { |i| i["type"] == "comments" }).to eq 1
        end
      end
    end
  end
end

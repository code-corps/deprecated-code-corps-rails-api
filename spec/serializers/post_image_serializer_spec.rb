# == Schema Information
#
# Table name: post_images
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  post_id            :integer          not null
#  filename           :text             not null
#  base64_photo_data  :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

require "rails_helper"

describe PostImageSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:gif_string) {
      file = File.open("#{Rails.root}/spec/sample_data/base64_images/gif.txt", 'r')
      open(file) { |io| io.read }
    }
    let(:resource) { create(:post_image, :with_s3_image, filename: "default-avatar.gif", base64_photo_data: gif_string) }

    let(:serializer) { PostImageSerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'post_images'" do
        expect(subject["type"]).to eq "post_images"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'filename'" do
        expect(subject["filename"]).to eql resource.filename
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

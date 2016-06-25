# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

require "rails_helper"

describe CategorySerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) do
      create(:category)
    end

    let(:serializer) { CategorySerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has no relationships object" do
        expect(subject["relationships"]).to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'categories'" do
        expect(subject["type"]).to eq "categories"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'name'" do
        expect(subject["name"]).to eql resource.name
        expect(subject["name"]).to_not be_nil
      end

      it "has a 'slug'" do
        expect(subject["slug"]).to eql resource.slug
        expect(subject["slug"]).to_not be_nil
      end

      it "has a 'description'" do
        expect(subject["description"]).to eql resource.description
        expect(subject["description"]).to_not be_nil
      end
    end
  end
end

require "rails_helper"

describe UserCategorySerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:user_category) }

    let(:serializer) { UserCategorySerializer.new(resource) }
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

      it "has a type set to 'user_categories'" do
        expect(subject["type"]).to eq "user_categories"
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

      it "should contain a 'category' relationship" do
        expect(subject["category"]).not_to be_nil
        expect(subject["category"]["data"]["type"]).to eq "categories"
        expect(subject["category"]["data"]["id"]).to eq resource.category.id.to_s
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
          expect(subject.select { |i| i["type"] == "users" }.length).to eq 1
        end
      end

      context "when including 'category'" do
        let(:serialization) do
          ActiveModel::Serializer::Adapter.create(serializer, include: ["category"])
        end

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should not be empty" do
          expect(subject).not_to be_nil
          expect(subject.select { |i| i["type"] == "categories" }.length).to eq 1
        end
      end
    end
  end
end

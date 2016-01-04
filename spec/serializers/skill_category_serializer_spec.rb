require "rails_helper"

describe SkillCategorySerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      skill_category = create(:skill_category)
      create_list(:skill, 10, skill_category: skill_category)
      skill_category
    }

    let(:serializer) { SkillCategorySerializer.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "has a relationships object" do
        expect(subject["relationships"]).not_to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'projects'" do
        expect(subject["type"]).to eq "skill_categories"
      end
    end

    context "attributes" do

      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'title'" do
        expect(subject["title"]).to eql resource.title
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "has a skills relationship" do
        expect(subject["skills"]).not_to be_nil
        expect(subject["skills"]["data"].length).to eq 10
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

      context "when including skills" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["skills"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the skill category's skills" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "skills"}.length).to eq 10
        end
      end
    end
  end
end

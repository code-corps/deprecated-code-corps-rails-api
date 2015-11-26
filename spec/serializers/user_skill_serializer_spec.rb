require "rails_helper"

describe UserSkillSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      create(:user_skill)
    }

    let(:serializer) { UserSkillSerializer.new(resource) }
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

      it "has a type set to 'user_skills'" do
        expect(subject["type"]).to eq "user_skills"
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

      it "should contain a 'skill' relationship" do
        expect(subject["skill"]).not_to be_nil
        expect(subject["skill"]["data"]["type"]).to eq "skills"
        expect(subject["skill"]["data"]["id"]).to eq resource.skill.id.to_s
      end
    end

    context "included" do
      subject do
        JSON.parse(serialization.to_json)["included"]
      end

      it "should be empty" do
        expect(subject).to be_nil
      end
    end
  end
end

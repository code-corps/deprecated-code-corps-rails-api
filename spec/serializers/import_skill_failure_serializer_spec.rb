# == Schema Information
#
# Table name: import_skill_failures
#
#  id         :integer          not null, primary key
#  import_id  :integer          not null
#  skill_id   :integer
#  data       :json             not null
#  issues     :text             not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe ImportSkillFailureSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:import_skill_failure) }

    let(:serializer) { described_class.new(resource) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

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

      it "has a type set to 'import_skill_failures'" do
        expect(subject["type"]).to eq "import_skill_failures"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has an 'issues' property" do
        expect(subject["issues"]).to_not be_nil
        expect(subject["issues"]).to eql resource.issues
      end

      it "has a 'data' property" do
        expect(subject["data"]).to_not be_nil
        expect(subject["data"]).to eql resource.data
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'import' relationship" do
        expect(subject["import"]).not_to be_nil
        expect(subject["import"]["data"]["type"]).to eq "imports"
        expect(subject["import"]["data"]["id"]).to eq resource.import.id.to_s
      end

      it "should contain a 'skill' relationship" do
        expect(subject["skill"]).not_to be_nil
        expect(subject["skill"]["data"]["type"]).to eq "skills"
        expect(subject["skill"]["data"]["id"]).to eq resource.skill.id.to_s
      end
    end
  end
end

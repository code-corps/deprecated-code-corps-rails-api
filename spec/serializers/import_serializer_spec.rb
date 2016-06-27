# == Schema Information
#
# Table name: imports
#
#  id                :integer          not null, primary key
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  status            :integer          default(0)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require "rails_helper"

describe ImportSerializer, type: :serializer do
  context "individual resource representation" do
    let(:resource) { create(:import) }

    let(:serializer) { described_class.new(resource) }
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

      it "has a type set to 'imports'" do
        expect(subject["type"]).to eq "imports"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has an 'status' property" do
        expect(subject["status"]).to_not be_nil
        expect(subject["status"]).to eql resource.status
      end

      it "has a 'file_name' property" do
        expect(subject["file_name"]).to_not be_nil
        expect(subject["file_name"]).to eql resource.file_file_name
      end
    end
  end
end

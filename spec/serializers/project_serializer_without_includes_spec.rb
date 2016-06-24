require "rails_helper"

describe ProjectSerializerWithoutIncludes, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      project = create(:project)
      create_list(:github_repository, 10, project: project)
      project
    }

    let(:serializer) { ProjectSerializerWithoutIncludes.new(resource) }
    let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

    context "root" do
      subject do
        JSON.parse(serialization.to_json)["data"]
      end

      it "has an attributes object" do
        expect(subject["attributes"]).not_to be_nil
      end

      it "does not have a relationships object" do
        expect(subject["relationships"]).to be_nil
      end

      it "has an id" do
        expect(subject["id"]).not_to be_nil
      end

      it "has a type set to 'projects'" do
        expect(subject["type"]).to eq "projects"
      end
    end

    context "attributes" do
      subject do
        JSON.parse(serialization.to_json)["data"]["attributes"]
      end

      it "has a 'title'" do
        expect(subject["title"]).to eql resource.title
      end

      it "has a 'description'" do
        expect(subject["description"]).to eql resource.description
      end

      it "has a 'long_description_body'" do
        expect(subject["long_description_body"]).to_not be_nil
        expect(subject["long_description_body"]).to eql resource.long_description_body
      end

      it "has a 'long_description_markdown'" do
        expect(subject["long_description_markdown"]).to_not be_nil
        expect(subject["long_description_markdown"]).to eql resource.long_description_markdown
      end

      it "has an 'closed_posts_count'" do
        expect(subject["closed_posts_count"]).to_not be_nil
        expect(subject["closed_posts_count"]).to eql resource.closed_posts_count
      end

      it "has an 'open_posts_count'" do
        expect(subject["open_posts_count"]).to_not be_nil
        expect(subject["open_posts_count"]).to eql resource.open_posts_count
      end
    end
  end
end

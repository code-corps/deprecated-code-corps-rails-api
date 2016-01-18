# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  title              :string           not null
#  description        :string
#  owner_id           :integer
#  owner_type         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  icon_file_name     :string
#  icon_content_type  :string
#  icon_file_size     :integer
#  icon_updated_at    :datetime
#  base64_icon_data   :text
#  contributors_count :integer
#  slug               :string           not null
#

require "rails_helper"

describe ProjectSerializer, :type => :serializer do

  context "individual resource representation" do
    let(:resource) {
      project = create(:project, :with_contributors, contributors_count: 5)
      create_list(:github_repository, 10, project: project)
      project
    }

    let(:serializer) { ProjectSerializer.new(resource) }
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

      it "has a 'contributors_count'" do
        expect(subject["contributors_count"]).to eql resource.contributors_count
      end
    end

    context "relationships" do
      subject do
        JSON.parse(serialization.to_json)["data"]["relationships"]
      end

      it "should contain a 'contributors' relationship" do
        expect(subject["contributors"]).not_to be_nil
        expect(subject["contributors"]["data"].count).to eq 5
      end

      it "should have a 'github_repositories' relationship" do
        expect(subject["github_repositories"]).not_to be_nil
        expect(subject["github_repositories"]["data"].length).to eq 10
        expect(subject["github_repositories"]["data"].all? { |r| r["type"] == "github_repositories" }).to be true
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
    end

    context "when including github_repositories" do
        let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer, include: ["github_repositories"]) }

        subject do
          JSON.parse(serialization.to_json)["included"]
        end

        it "should contain the user's github_repositories" do
          expect(subject).not_to be_nil
          expect(subject.select{ |i| i["type"] == "github_repositories"}.length).to eq 10
        end
      end
  end
end

require "rails_helper"

describe "Skills API" do

  context "GET /skills" do
    before do
      @skills = create_list(:skill, 10)
    end

    context "when successful" do
      before do
        get "#{host}/skills"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of skills, serialized using SkillSerializer, with skill includes" do
        expect(json).to serialize_collection(@skills)
                          .with(SkillSerializer)
      end
    end

  end
end

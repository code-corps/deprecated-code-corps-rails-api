require "rails_helper"

describe "SkillCategories API" do

  context "GET /skill_categories" do
    before do
      @skill_categories = create_list(:skill_category, 10)
    end

    context "when successful" do
      before do
        get "#{host}/skill_categories"
      end

      it "responds with a 200" do
        expect(last_response.status).to eq 200
      end

      it "returns a list of skill categories, serialized using SkillCategorySerializer, with skill includes" do
        expect(json).to serialize_collection(@skill_categories)
                          .with(SkillCategorySerializer)
                          .with_includes("skills")
      end
    end

  end
end

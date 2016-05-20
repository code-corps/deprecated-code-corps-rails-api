require "rails_helper"

RSpec.describe Category, type: :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:text) }
    it { should have_db_index(:slug).unique }
  end

  describe "relationships" do
    it { should have_many(:project_categories) }
    it { should have_many(:projects).through(:project_categories) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }

    it_behaves_like "a slug validating model", :slug

    describe "slug validation" do
      context "when a category with a different cased slug exists" do
        before do
          Category.create(name: "Politics")
        end

        it "should have the right errors" do
          category = Category.create(name: "politics")
          expect(category.errors.messages.count).to eq 1
          expect(category.errors.messages[:slug].first).to eq "has already been taken"
        end
      end

      context "when a category with the same slug exists" do
        before do
          Category.create(name: "Politics")
        end

        it "should have the right errors" do
          category = Category.create(name: "Politics")
          expect(category.errors.messages.count).to eq 1
          expect(category.errors.messages[:slug].first).to eq "has already been taken"
        end
      end
    end
  end
end

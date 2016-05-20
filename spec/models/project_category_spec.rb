require "rails_helper"

RSpec.describe ProjectCategory, type: :model do
  describe "schema" do
    it { should have_db_column(:project_id).of_type(:integer) }
    it { should have_db_column(:category_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:project) }
    it { should belong_to(:category) }
  end

  describe "validations" do
    it { should validate_presence_of :project }
    it { should validate_presence_of :category }

    describe "uniquness" do
      subject { create(:project_category) }

      it { should validate_uniqueness_of(:project_id).scoped_to(:category_id) }
    end
  end
end

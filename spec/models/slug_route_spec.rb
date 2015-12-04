require 'rails_helper'

RSpec.describe SlugRoute, type: :model do
  describe "schema" do
    it { should have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { should have_db_column(:owner_type).of_type(:string) }
    it { should have_db_column(:owner_id).of_type(:integer) }

    it { should have_db_index(:slug).unique(true) }
    it { should have_db_index([:owner_id, :owner_type]).unique(true) }
  end

  describe "relationships" do
    it { should belong_to(:owner) }
  end

  describe "validations" do
    describe "slug" do

      it { should validate_presence_of(:slug) }
      it { should validate_uniqueness_of(:slug).case_insensitive }
      it { should allow_value("code_corps").for(:slug) }
      it { should allow_value("codecorps").for(:slug) }
      it { should allow_value("codecorps12345").for(:slug) }
      it { should allow_value("code12345corps").for(:slug) }
      it { should allow_value("code____corps").for(:slug) }
      it { should allow_value("code-corps").for(:slug) }
      it { should allow_value("code-corps-corps").for(:slug) }
      it { should allow_value("code_corps_corps").for(:slug) }
      it { should allow_value("c").for(:slug) }
      it { should_not allow_value("-codecorps").for(:slug) }
      it { should_not allow_value("codecorps-").for(:slug) }
      it { should_not allow_value("@codecorps").for(:slug) }
      it { should_not allow_value("code----corps").for(:slug) }
      it { should_not allow_value("code/corps").for(:slug) }
      it { should_not allow_value("code_corps/code_corps").for(:slug) }
      it { should_not allow_value("code///corps").for(:slug) }
      it { should_not allow_value("@code/corps/code").for(:slug) }
      it { should_not allow_value("@code/corps/code/corps").for(:slug) }

      # Checks reserved routes
      it { should_not allow_value("help").for(:slug) }
    end

    it "should not create slugs with different case" do
      SlugRoute.create(owner_id: 1, owner_type: "User", slug: "codecorps")

      route = SlugRoute.new(owner_id: 2, owner_type: "User", slug: "CodeCorps")

      expect(route).to be_invalid
      expect(route.errors[:slug]).to include "has already been taken"
    end
  end

end

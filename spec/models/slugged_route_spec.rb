# == Schema Information
#
# Table name: slugged_routes
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe SluggedRoute, type: :model do
  describe "schema" do
    it { should have_db_column(:slug).of_type(:string) }
    it { should have_db_column(:owner_id).of_type(:integer) }
    it { should have_db_column(:owner_type).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:owner) }
  end

  describe "validations" do
    it_behaves_like "a slug validating model", :slug

    describe "slug" do
      it { should validate_presence_of(:slug) }
      it { should validate_uniqueness_of(:slug).case_insensitive }
      it { should validate_exclusion_of(:slug).in_array(Rails.configuration.x.reserved_routes) }

      Rails.configuration.x.reserved_routes.each do |route|
        it { should_not allow_value(route).for(:slug) }
      end
    end
  end
end

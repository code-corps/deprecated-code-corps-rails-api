# == Schema Information
#
# Table name: members
#
#  id         :integer          not null, primary key
#  slug       :string           not null
#  model_id   :integer
#  model_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Member, type: :model do
  describe "schema" do
    it { should have_db_column(:slug).of_type(:string) }
    it { should have_db_column(:model_id).of_type(:integer) }
    it { should have_db_column(:model_type).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:model) }
  end

  describe "validations" do

    describe "slug" do
      it { should validate_presence_of(:slug) }
      it { should validate_uniqueness_of(:slug).case_insensitive }
      it { should validate_exclusion_of(:slug).in_array(Rails.configuration.x.reserved_routes) }

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

      Rails.configuration.x.reserved_routes.each do |route|
        it { should_not allow_value(route).for(:slug) }
      end
    end
  end
end

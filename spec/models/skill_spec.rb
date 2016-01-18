# == Schema Information
#
# Table name: skills
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  description       :string
#  skill_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe Skill, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
    it { should have_db_column(:skill_category_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:skill_category) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:skill_category) }
  end
end

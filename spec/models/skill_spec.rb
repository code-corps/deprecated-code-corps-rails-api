# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

describe Skill, type: :model do
  describe "schema" do
    it { should have_db_column(:title).of_type(:string).with_options(null: false) }
    it { should have_db_column(:description).of_type(:string) }
  end

  describe "relationships" do
    it { should have_many(:role_skills) }
    it { should have_many(:roles).through(:role_skills) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end
end

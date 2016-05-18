# == Schema Information
#
# Table name: role_skills
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  skill_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe RoleSkill, type: :model do
  describe "schema" do
    it { should have_db_column(:role_id).of_type(:integer) }
    it { should have_db_column(:skill_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:role) }
    it { should belong_to(:skill) }
  end

  describe "validations" do
    it { should validate_presence_of :role }
    it { should validate_presence_of :skill }
    it { should validate_uniqueness_of(:role_id).scoped_to(:skill_id) }
  end
end

require 'rails_helper'

describe UserSkill, type: :model do
  describe "schema" do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:skill_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:skill) }
  end

  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :skill }
  end
end

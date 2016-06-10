# == Schema Information
#
# Table name: project_roles
#
#  id         :integer          not null, primary key
#  project_id :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe ProjectRole, type: :model do
  describe "schema" do
    it { should have_db_column(:project_id).of_type(:integer) }
    it { should have_db_column(:role_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:project) }
    it { should belong_to(:role) }
  end

  describe "validations" do
    it { should validate_presence_of :project }
    it { should validate_presence_of :role }

    describe "uniquness" do
      subject { create(:project_role) }

      it { should validate_uniqueness_of(:project_id).scoped_to(:role_id) }
    end
  end
end

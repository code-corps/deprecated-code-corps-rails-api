# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe UserRole, type: :model do
  describe "schema" do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:role_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end

  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :role }
    it { should validate_uniqueness_of(:user_id).scoped_to(:role_id) }
  end
end

# == Schema Information
#
# Table name: user_categories
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require "rails_helper"

RSpec.describe UserCategory, type: :model do
  describe "schema" do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:category_id).of_type(:integer) }
  end

  describe "relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end

  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :category }

    describe "uniquness" do
      subject { create(:user_category) }

      it { should validate_uniqueness_of(:user_id).scoped_to(:category_id) }
    end
  end
end

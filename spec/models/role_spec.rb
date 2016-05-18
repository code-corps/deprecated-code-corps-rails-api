# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#

require 'rails_helper'

describe Role, type: :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:ability).of_type(:string).with_options(null: false) }
  end

  describe "relationships" do
    it { should have_many(:role_skills) }
    it { should have_many(:skills).through(:role_skills) }
  end
end

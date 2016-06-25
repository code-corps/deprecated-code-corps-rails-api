# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string           not null
#  ability    :string           not null
#  kind       :string           not null
#

require "rails_helper"

describe Role, type: :model do
  describe "schema" do
    it { should have_db_column(:name).of_type(:string).with_options(null: false) }
    it { should have_db_column(:ability).of_type(:string).with_options(null: false) }
    it { should have_db_column(:kind).of_type(:string).with_options(null: false) }
  end

  describe "relationships" do
    it { should have_many(:role_skills) }
    it { should have_many(:skills).through(:role_skills) }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :ability }
    it { should validate_presence_of :kind }
  end

  it "should have a working 'kind' enum" do
    role = create(:role, kind: "technology")

    expect(role.technology?).to be true
    expect(role.creative?).to be false
    expect(role.support?).to be false

    role.creative!
    expect(role.technology?).to be false
    expect(role.creative?).to be true
    expect(role.support?).to be false

    role.support!
    expect(role.technology?).to be false
    expect(role.creative?).to be false
    expect(role.support?).to be true
  end
end

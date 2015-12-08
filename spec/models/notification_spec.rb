require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "schema" do
    it { should have_db_column(:notifiable_id).of_type(:integer) }
    it { should have_db_column(:notifiable_type).of_type(:string) }
  end

  describe "relationships" do
    it { should belong_to(:notifiable) }
  end

  describe "validations" do
    it { should validate_presence_of(:notifiable) }
  end
end

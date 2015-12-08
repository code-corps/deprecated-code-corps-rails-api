require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "schema" do
    it { should have_db_column(:notifiable_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:notifiable_type).of_type(:string).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  end

  describe "relationships" do
    it { should belong_to(:notifiable) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:notifiable) }
    it { should validate_presence_of(:user) }

    it "should have a unique user_id scoped to notifable" do
      user = create(:user)
      post = create(:post)
      create(:notification, user: user, notifiable: post)
      expect {
        create(:notification, user: user, notifiable: post)
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: User has already been taken")
    end
  end
end

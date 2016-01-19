# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  notifiable_id   :integer          not null
#  notifiable_type :string           not null
#  user_id         :integer          not null
#  aasm_state      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "schema" do
    it { should have_db_column(:notifiable_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:notifiable_type).of_type(:string).with_options(null: false) }
    it { should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:aasm_state).of_type(:string) }
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

  describe "state machine" do
    let(:notification) { Notification.new }

    it "sets the state to pending initially" do
      expect(notification).to have_state(:pending)
    end

    it "transitions correctly" do
      expect(notification).to transition_from(:pending).to(:sent).on_event(:dispatch)
      expect(notification).to transition_from(:pending).to(:read).on_event(:mark_as_read)
      expect(notification).to transition_from(:sent).to(:read).on_event(:mark_as_read)
    end
  end
end

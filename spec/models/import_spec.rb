# == Schema Information
#
# Table name: imports
#
#  id         :integer          not null, primary key
#  status     :integer
#  file       :attachment

require "rails_helper"

describe Import, type: :model do
  describe "after_create" do
    subject { create(:import) }

    it "calls perform method" do
      expect { subject }.to change(PerformImportWorker.jobs, :size).by(1)
    end
  end
end

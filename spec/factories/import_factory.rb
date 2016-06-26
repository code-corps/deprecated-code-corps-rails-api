# == Schema Information
#
# Table name: imports
#
#  id         :integer          not null, primary key
#  status     :integer
#  file       :attachment

FactoryGirl.define do

  factory :import do
    status :unprocessed
    file { File.new(Rails.root.join('spec', 'sample_data', 'import.csv')) } 
  end

end

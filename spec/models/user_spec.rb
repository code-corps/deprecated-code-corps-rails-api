require 'rails_helper'

describe User, :type => :model do

  let(:user) { User.create(email: "joshdotsmith@gmail.com", username: "joshsmith", password: "password") }

  it "is not an admin by default" do
    expect(user.admin?).to eq false
  end

  it "knows when it is an admin" do
    user.admin = true
    user.save
    expect(user.admin?).to eq true
  end

end

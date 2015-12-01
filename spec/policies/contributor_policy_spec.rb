require 'rails_helper'

describe ContributorPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end

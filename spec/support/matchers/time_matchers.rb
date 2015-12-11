RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    expect(Date.parse(expected.to_s)).to eq(Date.parse(actual))
  end
end

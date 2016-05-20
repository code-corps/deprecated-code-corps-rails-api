RSpec.shared_examples "a slug validating model" do |column|
  it { should allow_value("code_corps").for(column) }
  it { should allow_value("codecorps").for(column) }
  it { should allow_value("codecorps12345").for(column) }
  it { should allow_value("code12345corps").for(column) }
  it { should allow_value("code____corps").for(column) }
  it { should allow_value("code-corps").for(column) }
  it { should allow_value("code-corps-corps").for(column) }
  it { should allow_value("code_corps_corps").for(column) }
  it { should allow_value("c").for(column) }
  it { should_not allow_value("-codecorps").for(column) }
  it { should_not allow_value("codecorps-").for(column) }
  it { should_not allow_value("@codecorps").for(column) }
  it { should_not allow_value("code----corps").for(column) }
  it { should_not allow_value("code/corps").for(column) }
  it { should_not allow_value("code_corps/code_corps").for(column) }
  it { should_not allow_value("code///corps").for(column) }
  it { should_not allow_value("@code/corps/code").for(column) }
  it { should_not allow_value("@code/corps/code/corps").for(column) }
end

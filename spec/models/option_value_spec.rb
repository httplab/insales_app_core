require 'spec_helper'

describe OptionValue do
  it { should validate_presence_of :title }
  it { should validate_presence_of :insales_id }
  it { should validate_presence_of :account }
  it { should validate_presence_of :option_name_id }
end

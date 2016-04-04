require 'spec_helper'

describe OptionName do
  it { should validate_presence_of :title }
  it { should validate_presence_of :insales_id }
  it { should validate_presence_of :account }
end

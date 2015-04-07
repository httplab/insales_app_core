require 'spec_helper'

describe ClientGroup do
  it { should have_many :clients }
  it { should belong_to :account }
  it { should validate_presence_of :title }
end

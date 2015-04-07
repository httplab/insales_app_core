require 'spec_helper'

describe Client do
  it { should belong_to(:client_group) }
  it { should belong_to(:account) }
end

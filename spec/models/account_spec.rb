require 'spec_helper'

describe Account do
  it { should have_many(:client_groups) }
  it { should have_many(:clients) }

  let(:account) { Account.new }
  subject { account }

  its '#create_app returns InsalesApi::App instance' do
    expect(subject.create_app).to be_a InsalesApi::App
  end
end

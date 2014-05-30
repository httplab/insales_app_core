require_relative '../../spec_helper.rb'

describe 'Tariffication::Processor' do

  before :all do
    @account = build(:account)
    @account.stub(:configure_api, nil)
    @account.tariff_id = :test
    @account.save!
  end

  it 'should create instance' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
    end

    processor = Tariffication::Processor.new(@account.id, tc)
  end

  it 'should have action methods' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.limit_action :sms, 1000
      tariff.free_action :mail
    end

    processor = Tariffication::Processor.new(@account.id, tc)

    expect(processor).to respond_to(:before_sms)
    expect(processor).to respond_to(:after_sms)
    expect(processor).to respond_to(:can_sms?)
    expect(processor).to respond_to(:perform_sms)

    expect(processor).to respond_to(:before_mail)
    expect(processor).to respond_to(:after_mail)
    expect(processor).to respond_to(:can_mail?)
    expect(processor).to respond_to(:perform_mail)
  end

  it 'should write installation date' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
    end

    processor = Tariffication::Processor.new(@account.id, tc)
    processor.install
    expect(@account.tariff_info[:installation_date]).not_to be_empty
  end


end

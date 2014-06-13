require_relative '../../spec_helper.rb'

describe Tariffication::Processor do

  before :each do
    @account = build(:account)
    @account.stub(:configure_api){nil}
    InsalesApi::RecurringApplicationCharge.stub(:create) do |price|
      nil
    end
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
    @account.reload
    expect(@account.tariff_data['installation_date']).not_to be_empty
    expect(@account.tariff_data['period_start']).not_to be_empty
  end

  it 'should set limits' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.limit_action :sms, 21
    end

    processor = Tariffication::Processor.new(@account.id, tc)
    processor.install
    @account.reload
    expect(@account.tariff_data['sms_limit']).to eq(21)
  end

  it 'shout increase used count' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.limit_action :sms, 21
    end

    processor = Tariffication::Processor.new(@account.id, tc)
    processor.install
    @account.reload
    expect(@account.tariff_data['sms_used']).to eq(0)
    processor.perform_sms
    @account.reload
    expect(@account.tariff_data['sms_used']).to eq(1)
    processor.perform_sms
    @account.reload
    expect(@account.tariff_data['sms_used']).to eq(2)
  end

  it 'should always allow free actions' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.free_action :mail
    end

    processor = Tariffication::Processor.new(@account.id, tc)
    processor.install

    10.times do
      expect(processor).to be_can_mail
      processor.perform_mail
    end
  end

  it 'should disallow action after hitting limit' do
    tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.limit_action :sms, 1
    end

    processor = Tariffication::Processor.new(@account.id, tc)
    processor.install

    expect(processor).to be_can_sms
    expect(processor.get_sms_used).to eq(0)
    sent_count = 0

    processor.perform_sms do
      sent_count += 1;
    end
    expect(sent_count).to eq(1)
    expect(processor.get_sms_used).to eq(1)
    expect(processor).not_to be_can_sms

    processor.perform_sms do
      sent_count += 1;
    end

    expect(sent_count).to eq(1)
  end


end

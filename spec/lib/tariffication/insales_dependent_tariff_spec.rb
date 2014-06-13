require_relative '../../spec_helper.rb'

describe Tariffication::InsalesDependentTariff do

  before :each do
    @account = build(:account)
    @account.stub(:configure_api){nil}
    InsalesApi::RecurringApplicationCharge.stub(:create) {nil}
    @account.tariff_id = :test
    @account.save!

    @tc = Tariffication::TariffConfiguration.new do |tariff|
      tariff.name = :test
      tariff.classname = 'Tariffication::InsalesDependentTariff'
      tariff.options = {
        'Премиум' => {price: 3500},
        :default => {price: 200}
      }
    end
  end

  it 'should create instance' do
    processor = described_class.new(@account.id, @tc)
  end

  it 'should have correct options' do
    processor = described_class.new(@account.id, @tc)

    expect(processor.send(:options)['Премиум'][:price]).to eq(3500)
    expect(processor.send(:options)[:default][:price]).to eq(200)
  end

  it 'should calculate price' do
    InsalesApi::Account.stub(:current) do
      cl = Struct.new(:plan_name).new('Премиум')
    end

    processor = described_class.new(@account.id, @tc)

    expect(processor.send(:account_params)[:price]).to eq(3500)
  end

  it 'should use default price' do
    InsalesApi::Account.stub(:current) do
      cl = Struct.new(:plan_name).new('Супер')
    end

    processor = described_class.new(@account.id, @tc)
    expect(processor.send(:account_params)[:price]).to eq(200)
  end

  it 'should install' do
    InsalesApi::Account.stub(:current) do
      cl = Struct.new(:plan_name).new('Премиум')
    end

    processor = described_class.new(@account.id, @tc)
    processor.install
    @account.reload
    expect(@account.tariff_id).to eq('test')
    expect(@account.tariff_data['price']).to eq(3500)
    expect(@account.tariff_data['installation_date']).not_to be_empty
    expect(@account.tariff_data['period_start']).not_to be_empty
  end


end

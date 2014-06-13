module Tariffication
  class InsalesDependentTariff < Processor 

    def install
      account.configure_api
      price = account_params[:price]
      InsalesApi::RecurringApplicationCharge.create(monthly: price)
      account.tariff_data = {}
      set_price(price)
      set_installation_date(DateTime.now)
      init_period
    end

    protected

    def options
      @config.options || {}
    end

    def map_insales(insales_tariff_name)
      options[insales_tariff_name] || options[:default] || {price: 0}
    end

    def account_params
      @account_params if @account_params
      insales_tariff_name = InsalesApi::Account.current.plan_name
      @account_params = map_insales(insales_tariff_name)
    end
  end

end

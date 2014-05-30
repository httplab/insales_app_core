module Tariffication
  class Processor

    def initialize(account_id, tariff_conf)
      @account_id = account_id
      @config = tariff_conf
      build_actions(@config.limit_actions.keys)
      build_actions(@config.free_actions)
    end

    def install
      account.configure_api
      InsalesApi::RecurringApplicationCharge.create(monthly: @config.base_price)
      account.tariff_info = {}
      installation_date = DateTime.now
      init_period
    end

    def init_period
      period_start = DateTime.now

      @config.limit_actions.each do |k,v|
        set_limit(k, v)
        set_used(k, 0)
      end

      @config.free_actions.each do |k|
        set_used(k, 0)
      end
      account.save!
    end

    def uninstall
      account.configure_api
      InsalesApi::RecurringApplicationCharge.instance.destroy
      account.tariff_info = nil
      account.save!
    end

    protected

    def build_actions(actions)
      actions.each do |k|
        define_singleton_method("before_#{k}") do |*args|
          before(k, *args)
        end

        define_singleton_method("after_#{k}") do |*args|
          after(k, *args)
        end

        define_singleton_method("can_#{k}?") do |*args|
          can_do?(k, *args)
        end

        define_singleton_method("perform_#{k}") do |*args, &blck|
          perform(k, *args, blck)
        end
      end
    end

    def can_do?(action, *args)
      if @config.limit_actions.has_key?(action)
        limit(action) > used(action)
      elsif @config.free_actions.include?(action)
        true
      else
        false
      end
    end

    def before(action, *args); end

    def after(action, *args)
      if @config.limit_actions.has_key?(action) || @config.free_actions.include?(action)
        set_used(action, used(action)+1)
      end
    end

    def perform(action, *args, &block)
      if can_do?(action)
        before(action)
        block.call if block_given?
        after(action)
      end
    end

    def limit(action_name)
      send("#{action_name}_limit")
    end

    def set_limit(action_name, value)
      send("#{action_name}_limit=", value)
    end

    def used(action_name)
      send("#{action_name}_used")
    end

    def set_used(action_name, value)
      send("#{action_name}_used=", value)
    end

    def account
      @account ||= Account.find(@account_id)
    end

  end
end

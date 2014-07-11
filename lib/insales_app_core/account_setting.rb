class InsalesAppCore::AccountSetting
  attr_accessor :name, :title, :description, :type, :control, :required

  def initialize(&block)
    block.call(self) if block_given?
  end

  def get_value(raw_value, acc)
    if raw_value.nil?
      val = @default_value.respond_to?(:call) ? @default_value.call(acc) : @default_value
      return val.nil? ? nil : get_value(val, acc)
    end

    case @type
    when :integer
      raw_value.to_i
    else
      raw_value
    end
  end

  def prepare_value(user_value)
    user_value
  end

  def default_value(val = nil, &block)
    @default_value = val || block
  end
  
end

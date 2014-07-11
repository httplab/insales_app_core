class InsalesAppCore::AccountSetting
  attr_accessor :name, :title, :description, :type, :control, :default_value, :required

  def initialize(&block)
    block.call(self) if block_given?
  end

  def get_value(raw_value)
    return @default_value if raw_value.nil?

    case :type
    when :integer
      raw_value.to_i
    else
      raw_value
    end
  end

  def prepare_value(user_value)
    user_value
  end
  
end

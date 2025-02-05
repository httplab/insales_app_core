class InsalesAppCore::AccountSetting
  attr_accessor :name, :title, :description, :type, :control, :required

  def initialize(&block)
    block.call(self) if block_given?
  end

  def get_value(raw_value, acc)
    if raw_value.nil?
      val = @default_value.respond_to?(:call) ? @default_value.call(acc) : @default_value
      if val.nil?
        return nil
      else
        val = get_value(val, acc)
        acc.set_setting(self.name, val)
        return val
      end
    end

    case @type
    when :integer
      raw_value.to_i
    when :boolean
      [1, '1', 'true', true, 'on', :on, :true].include?(raw_value)
    when :string_set
      raw_value.split('%')
    else
      raw_value
    end
  end

  def prepare_value(user_value)
    case @type
    when :boolean
      if [1, '1', 'true', true, 'on', :on, :true].include?(user_value)
        'true'
      else
        'false'
      end
    when :string_set
      user_value.map(&:to_s).uniq.join('%')
    else
      user_value
    end
  end

  def default_value(val = nil, &block)
    @default_value =
      if val.nil?
        block
      else
        val
      end
  end

  def allowed_values=(val = nil, &block)
    @allowed_values = val || block
  end

  def allowed_values(acc)
    if @allowed_values.respond_to?(:call)
      @allowed_values.call(acc)
    else
      @allowed_values
    end
  end

end

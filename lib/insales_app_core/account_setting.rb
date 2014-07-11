class InsalesAppCore::AccountSetting
  attr_accessor :name, :title, :description, :type, :control, :default_value

  def initialize(&block)
    block.call(self) if block_given?
  end
  
end

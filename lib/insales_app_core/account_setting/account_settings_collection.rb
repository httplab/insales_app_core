class InsalesAppCore::AccountSetting::AccountSettingsCollection
  include Enumerable

  attr_reader :settings

  def initialize(&block)
    @settings ||= []
    block.call(self) if block_given?
  end

  def setting(&block)
    @settings << InsalesAppCore::AccountSetting.new(&block) if block_given?
  end

  def each(&block)
    @settings.each(&block)
  end
end

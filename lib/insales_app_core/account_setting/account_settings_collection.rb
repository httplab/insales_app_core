class InsalesAppCore::AccountSetting::AccountSettingsCollection
  include Enumerable

  attr_reader :settings

  def initialize(&block)
    @settings ||= []
    @s_hash = {}
    block.call(self) if block_given?
  end

  def setting(&block)
    s = InsalesAppCore::AccountSetting.new(&block) if block_given?
    @settings << s
    @s_hash[s.name] = s
  end

  def each(&block)
    @settings.each(&block)
  end

  def get_value(acc, name)
    setting = acc.settings.find_by_name(name)
    val = setting.nil? ? nil : setting.value
    @s_hash[name].get_value(val, acc)
  end

  def set_value(acc, name, value)
    setting = @s_hash[name]
    if !setting
      raise "Trying to set unknown setting '#{name}'"
    end

    if value.nil? && setting.required
      raise "Nil value for required setting '#{name}'"
    end

    db_setting = acc.settings.find_by_name(name)

    if !db_setting
      db_setting = acc.settings.create(name: name, account: acc, value: setting.prepare_value(value))
    else
      db_setting.value = setting.prepare_value(value)
      db_setting.save!
    end

  end
end

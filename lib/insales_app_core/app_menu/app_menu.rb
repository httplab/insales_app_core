class InsalesAppCore::AppMenu
  attr_accessor :items
  attr_accessor :active_item

  def initialize(&block)
    self.items = []
    block.call(self) if block_given?
  end

  def add_item(title, params = {}, &block)
    items << MenuItem.new(title, params, &block)
  end

  def add_home
    items << MenuItem.new('home').tap do |i|
      i.path = '/'
      i.home = true
    end
  end

  def set_active_flags(path)
    # Заполняем текущий активный элемент при каждом перестроении меню.
    self.active_item = nil

    items.each do |item|
      # Пункт считаем активным, если его path, или path кого-либо из подменю совпадает
      # с request.path
      active_current = (path.index(item.clean_path) == 0)
      active_somebody_in_submenu = item.submenu && item.submenu.set_active_flags(path)

      if item.active = active_current || active_somebody_in_submenu
        self.active_item = item
      end
    end

    !!active_item
  end
end

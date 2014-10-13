module InsalesAppCore
  class Admin::Configuration

    def initialize(&blk)
      blk.call self if block_given?
    end

    def left_menu(&block)
      if block_given?
        @left_menu = InsalesAppCore::AppMenu.new(&block)
      end
      @left_menu
    end

    def right_menu(&block)
      if block_given?
        @right_menu = InsalesAppCore::AppMenu.new(&block)
      end
      @right_menu
    end
  end
end

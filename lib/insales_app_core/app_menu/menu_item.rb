class InsalesAppCore::AppMenu::MenuItem
  attr_accessor :submenu
  attr_accessor :home
  attr_accessor :active
  attr_reader :active_regex

  alias_method :home?, :home
  alias_method :active?, :active

  def initialize(title, path_params = {}, &block)
    @title = title

    if block_given?
      self.submenu = InsalesAppCore::AppMenu.new(&block)
    end

    if path_params.is_a? String
      self.path = path_params
    elsif path_params.is_a? Hash
      self.path = path_params[:path]
      @active_regex = path_params[:active_regex]
    end
  end

  def has_submenu?
    !!submenu
  end

  def clean_path
    return nil unless path
    URI.parse(path).path
  end

  def path
    if has_submenu?
      submenu.items.first.path
    else
      @path
    end
  end

  def path=(str)
    @path = str
  end

  def title
    I18n.t(@title)
  end
end

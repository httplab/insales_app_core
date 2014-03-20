module InsalesAppCoreHelper
  def app_name
    I18n.t(:app_name, default: I18n.t(:default_app_name))
  end

  def title(str)
    content_for(:page_title) { str }
    str
  end

  def render_title
    if content_for? :page_title
      [content_for(:page_title), app_name].join(' – ')
    else
      app_name
    end
  end
end

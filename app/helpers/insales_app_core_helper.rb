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

  def insales_admin_order_url(order)
    id = if order.is_a?(Order)
      order.insales_id
    elsif order.is_a?(InsalesApi::Order)
      order.id
    elsif !(ord = Order.find_by_number(order)).nil?
      ord.insales_id
    elsif !(ord = Order.find_by_id(order)).nil?
      ord.insales_id
    end

    if !id.nil?
      "http://#{current_account.insales_subdomain}/admin/orders/#{id}"
    end
  end

  # Сгенерировать линк на страницу в настройках магазина insales,
  # в противном случае вернуть nil.
  def auth_insales_admin_url_for(section)
    if logged_in?
      File.join("http://#{current_account.insales_subdomain}", section)
    end
  end

  def insales_admin_order_link(order, text=nil)
    text ||= order.number
    link_to(text, insales_admin_order_url(order))
  end

  def shop_product_url(product)
    account = product.account
    File.join(account.get_setting(:shop_url), 'product', product.permalink)
  end

  def auth_link_to(name = nil, options = nil, html_options = nil, &block)
    unless logged_in?
      modal_hsh = { data: { toggle: 'modal', target: '#unlogged-modal' } }
      if block_given?
        options ||= {}
        options.reverse_merge!(modal_hsh)
        name = '#'
      else
        html_options ||= {}
        html_options.reverse_merge!(modal_hsh)
        options = '#'
      end
    end

    link_to name, options, html_options, &block
  end

  def controller_action_class
    [controller.class.name.underscore.parameterize.dasherize, action_name].join(' ')
  end
end


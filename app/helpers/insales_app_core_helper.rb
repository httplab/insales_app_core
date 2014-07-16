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

  def insales_admin_order_link(order, text=nil)
    text ||= order.number
    link_to(text, insales_admin_order_url(order))
  end

  def shop_product_url(product)
    account = product.account
    File.join(account.get_setting(:shop_url), 'product', product.permalink)
  end
end


module AppMenuHelper
  def render_app_menu
    left_menu = InsalesAppCore.config.left_menu
    right_menu = InsalesAppCore.config.right_menu

    # Расставляем признаки активности для пунктов меню исходя из текущего request.path
    left_menu.set_active_flags(request.path)
    right_menu.set_active_flags(request.path)

    active_item = left_menu.active_item || right_menu.active_item

    # Рендерим меню верхнего уровня, левое и правое
    markup = content_tag(:ul, class: 'nav nav-tabs') do
      left_menu.items.each do |item|
        concat(render_app_menu_item(item))
      end

      right_menu.items.reverse.each do |item|
        concat(render_app_menu_item(item, right_side: true))
      end
    end

    # Рендерим подменю, если таковое имеется
    if active_item.submenu
      markup += content_tag(:ul, class: 'nav nav-pills', id: 'app-submenu') do
        active_item.submenu.items.each do |item|
          concat(render_app_menu_item(item))
        end
      end
    end

    markup
  end

  def render_app_menu_item(item, right_side: false)
    classes = []
    classes << 'active' if item.active?
    classes << 'pull-right' if right_side
    classes = classes.join(' ')

    content_tag :li, class: classes do
      if item.home?
        link_to root_path do
          content_tag(:span, class: 'glyphicon glyphicon-home') {}
        end
      else
        link_to item.title, item.path
      end
    end
  end
end

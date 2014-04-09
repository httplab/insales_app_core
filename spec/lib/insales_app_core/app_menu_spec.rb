require 'spec_helper'

describe InsalesAppCore::AppMenu do
  it 'allow to add menu items' do
    menu = InsalesAppCore::AppMenu.new do |m|
      m.add_item 'title'
      m.add_item 'title1'
    end
    expect(menu.items.count).to eq 2
  end

  it 'allow to create submenu for item' do
    menu = InsalesAppCore::AppMenu.new do |m|
      m.add_item 'title'
      m.add_item 'title1' do |sub|
        sub.add_item 'subtitle1'
      end
      m.add_item 'title2'
    end

    expect(menu.items[1]).to be_has_submenu
    expect(menu.items[1].submenu.items.count).to eq 1
  end

  it 'set active item for REST sections in path' do
    menu = InsalesAppCore::AppMenu.new do |m|
      m.add_item 'title', '/resources'
    end

    menu_item = menu.items.first
    menu.set_active_flags('/resources/new')

    expect(menu_item).to be_active
  end
end

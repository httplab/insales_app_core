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

  context 'submenu' do
    it 'have parent item'
  end
end

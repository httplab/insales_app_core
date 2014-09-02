class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    if logged_in?
      'application'
    else
      'wo_authorization'
    end
  end
end

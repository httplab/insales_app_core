class Admin::ApplicationController < ActionController::Base
  layout 'admin'
  before_filter :authenticate

  private

  def authenticate
    if ENV['ADMIN_LOGIN'].blank? || ENV['ADMIN_PASSWORD'].blank?
      render text: 'Authentication not configured', status: :unauthorized
    else
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['ADMIN_LOGIN'] && password == ENV['ADMIN_PASSWORD']
      end
    end
  end
end

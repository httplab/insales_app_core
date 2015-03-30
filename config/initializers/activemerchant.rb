require 'active_merchant'
require 'offsite_payments'

ActionView::Base.send(:include, OffsitePayments::ActionViewHelper)

OffsitePayments.mode = Rails.env.production? ? :production : :test

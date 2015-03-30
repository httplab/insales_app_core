class RobokassaController < ApplicationController
  include OffsitePayments::Integrations

  skip_before_action(
    :verify_authenticity_token,
    :authenticate,
    :configure_api,
    :store_after_sign_in_location
  )

  # Robokassa call this action after transaction
  def paid
    notification = Robokassa::Notification.new(request.raw_post, secret: ENV['ROBOKASSA_PASSWORD2'])

    item = BalanceReplenishment.find(notification.item_id)
    Rollbar.info('RobokassaController#paid', item: item,
                                             notification: notification)

    # check if it’s genuine Robokassa request
    if item.pending? &&
       notification.acknowledge &&
       notification.amount == item.amount

      Rails.logger.info "RobokassaPayment success. Item: [#{item.id}]"
      item.paid!
      Rollbar.info("Robokassa paid!", item: item,
                                      notification: notification)

      render text: notification.success_response
    else
      Rails.logger.warn "RobokassaPayment declined. Item: [#{item.id}]"
      Rollbar.info("Robokassa declined!", item: item,
                                          notification: notification)
      item.failed!
      on_payment_failed
    end

  rescue => e
    Rails.logger.info "=== #{e.message} #{e.backtrace} ==="
    Rollbar.error(e)
    item.try(:failed!)
    on_payment_failed
  end

  # Robokassa redirect user to this action if it’s all ok
  def success
    notification = Robokassa::Notification.new(request.raw_post, secret: ENV['ROBOKASSA_PASSWORD1'])
    unless Rails.env.test?
      raise 'Robokassa notification acknowledge fail' unless notification.acknowledge
    end

    item = BalanceReplenishment.find(notification.item_id)

    if item.paid?
      Rollbar.info("Robokassa success!", item: item,
                                         notification: notification)

      on_success
    else
      on_failed
    end
  end

  # Robokassa redirect user to this action if it’s not
  def fail
    notification = Robokassa::Notification.new(request.raw_post)
    item = BalanceReplenishment.find(notification.item_id)
    item.failed!

    Rollbar.info("Payment failed!", item: item, notification: notification)
    on_failed
  end

  private

  def on_payment_failed
    render text: 'failed'
  end

  def on_success
    redirect_to new_balance_replenishment_path, flash: { notice: t('robokassa.payment_success') }
  end

  def on_failed
    redirect_to new_balance_replenishment_path, flash: { alert: t('robokassa.payment_fail') }
  end
end

class BalanceChangesController < ApplicationController
  respond_to :html
  responders :flash

  has_scope :page, default: 1
  has_scope :per, default: 20
  has_scope :paid, type: :boolean, default: true
  has_scope :sorted_desc, type: :boolean, default: true

  def index
    @balance_changes = apply_scopes(current_account.balance_changes)
  end
end

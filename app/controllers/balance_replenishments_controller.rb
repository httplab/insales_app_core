class BalanceReplenishmentsController < ApplicationController
  respond_to :html
  responders :flash

  has_scope :page, default: 1
  has_scope :per, default: 20
  has_scope :paid, type: :boolean, default: true
  has_scope :sorted_desc, type: :boolean, default: true

  def index
    @balance_changes = apply_scopes(current_account.balance_replenishments)
  end

  def new
    @balance_replenishment = current_account.balance_replenishments.new(
      amount: BalanceReplenishment::DEFAULT_AMOUNT
    )
  end

  def create
    @balance_replenishment = current_account.balance_replenishments.create(balance_replenishment_params)

    if @balance_replenishment.save
      render 'create', layout: false
    else
      render 'new'
    end
  end

  private

  def balance_replenishment_params
    params.require(:balance_replenishment).permit(:amount)
  end
end

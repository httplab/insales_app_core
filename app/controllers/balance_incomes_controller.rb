class BalanceIncomesController < ApplicationController
  respond_to :html
  responders :flash

  def new
    @balance_income = current_account.balance_incomes.new(
      amount: BalanceIncome::DEFAULT_AMOUNT
    )
  end

  def create
    @balance_income = current_account.balance_incomes.create(balance_income_params)

    if @balance_income.save
      render 'create', layout: false
    else
      render 'new'
    end
  end

  private

  def balance_income_params
    params.require(:balance_income).permit(:amount)
  end
end

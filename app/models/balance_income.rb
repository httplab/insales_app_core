class BalanceIncome < BalanceChange
  DEFAULT_AMOUNT = 1000

  default_scope { where('amount > 0') }

  validates :amount, numericality: { greater_than: 0 }
end

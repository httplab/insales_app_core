class BalanceOutcome < BalanceChange
  default_scope { where('amount < 0') }

  validates :amount, numericality: { less_than: 0 }
end

class BalanceReplenishment < ActiveRecord::Base
  DEFAULT_AMOUNT = 1000
  belongs_to :account

  validates :account, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  scope :paid, -> { where('paid_at IS NOT NULL') }
  scope :failed, -> { where('failed_at IS NOT NULL') }
  scope :pending, -> { where(paid_at: nil).where(failed_at: nil) }
  scope :before_date, ->(date) { where('created_at <= ?', date) }
  scope :sorted_desc, -> { order('created_at DESC') }

  def pending?
    !paid? && !failed?
  end

  def paid?
    paid_at.present?
  end

  def failed?
    failed_at.present?
  end

  def paid!
    update_attribute(:paid_at, DateTime.current)
  end

  def failed!
    update_attribute(:failed_at, DateTime.current)
  end
end

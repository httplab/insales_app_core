class Variant < ActiveRecord::Base
  validates :account_id, :insales_id, :insales_product_id, presence: true
  belongs_to :account
  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id
  has_many :order_lines

  maps_to_insales product_id: :insales_product_id

  ADDL_PRICE_SET_ATTR_REX = /^price(?<price_id>\d+)=$/
  ADDL_PRICE_GET_ATTR_REX = /^price(?<price_id>\d+)$/


  def self.additional_prices_names
    uniq
      .where
      .not(additional_prices: nil)
      .pluck(:additional_prices)
      .map(&:keys)
      .flatten
      .uniq
      .map{ |n| "price#{n}" }
      .sort
  end

  def method_missing(method, *args)
    if (m = method.to_s.match(ADDL_PRICE_SET_ATTR_REX))
      set_additional_price(m[:price_id], args[0])
    elsif (m = method.to_s.match(ADDL_PRICE_GET_ATTR_REX))
      get_additional_price(m[:price_id])
    else
      super
    end
  end

  def set_additional_price(price_id, value)
    self.additional_prices = (additional_prices || {})
      .merge(price_id => value)
      .delete_if { |k,v| v.nil? }
  end

  def get_additional_price(price_id)
    v = (additional_prices || {})[price_id]
    v.to_f if v
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.match(ADDL_PRICE_SET_ATTR_REX) ||
    method_name.to_s.match(ADDL_PRICE_GET_ATTR_REX) ||
    super
  end

  def is_assignable_attribute?(v)
    v.to_s.match(ADDL_PRICE_GET_ATTR_REX).present? || super
  end
end

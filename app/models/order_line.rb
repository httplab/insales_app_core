class OrderLine < ActiveRecord::Base
  validates :insales_id, :product_id, :insales_product_id, :variant_id, :insales_variant_id,
            :quantity, :account_id, :order_id, :insales_order_id, presence: true

  belongs_to :order, dependent: :delete
  belongs_to :account
  belongs_to :variant
  belongs_to :product

  maps_to_insales product_id: :insales_product_id,
                  variant_id: :insales_variant_id
end

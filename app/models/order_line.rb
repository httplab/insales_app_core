class OrderLine < ActiveRecord::Base
  validates :insales_id, :insales_product_id, :insales_variant_id,
            :quantity, :account_id, :insales_order_id, presence: true

  belongs_to :order, dependent: :delete, primary_key: :insales_id, foreign_key: :insales_order_id
  belongs_to :account
  belongs_to :variant, primary_key: :insales_id, foreign_key: :insales_variant_id
  belongs_to :product, primary_key: :insales_id, foreign_key: :insales_product_id

  maps_to_insales product_id: :insales_product_id,
                  variant_id: :insales_variant_id
end

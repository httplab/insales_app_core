FactoryGirl.define do
  sequence :order_number do |n|
    n + 10_000
  end

  factory :order do
    insales_id
    accepted_at { Date.yesterday }
    comment { Faker::Lorem.sentence }
    delivery_description { Faker::Lorem.sentence }
    delivery_from_hour 9
    delivery_to_hour 18
    delivery_price { rand(30.0..500.0) }
    delivery_title { Faker::Lorem.word }
    insales_delivery_variant_id { generate(:insales_id) }
    financial_status 'pending'
    fulfillment_status 'new'
    number { generate(:order_number) }
    payment_description { Faker::Lorem.sentence }
    insales_payment_gateway_id { generate(:insales_id) }
    payment_title { Faker::Lorem.word }
    referer { Faker::Internet.url }
    items_price { rand(100.0..2000.0) }
    full_delivery_price { delivery_price + 100.0 }
    total_price { full_delivery_price + items_price }
    insales_client_id { generate(:insales_id) }

    trait :paid do
      financial_status 'paid'
      paid_at { Date.today }
    end

    trait :delivered do
      paid
      fulfillment_status 'delivered'
      delivered_at { Date.today }
      delivery_date { Date.toady }
    end
  end
end

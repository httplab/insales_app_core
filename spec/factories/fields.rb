FactoryGirl.define do
  factory :field do
    insales_id
    position 0
    active true
    for_buyer true
    obligatory false
    show_in_checkout true
    show_in_result true

    factory :client_field do
      destiny Field::DESTINY_CLIENT
    end

    factory :shipping_address_field do
      destiny Field::DESTINY_SHIPPING_ADDRESS
    end

    factory :order_field do
      destiny Field::DESTINY_ORDER
    end
  end
end

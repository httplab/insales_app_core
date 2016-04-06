FactoryGirl.define do
  factory :variant do
    insales_id
    account_id 1
    title { Faker::Lorem.word }
    sku { Faker::Lorem.word }
    product
    quantity 0
  end
end

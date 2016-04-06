FactoryGirl.define do
  factory :product do
    insales_id
    account_id 1
    title { Faker::Lorem.word }
    available true
    is_hidden false
  end
end

FactoryGirl.define do
  factory :client_group do
    insales_id
    dicount 0
    is_default false
    title { Faker::Lorem.word }
    discount_description { Faker::Lorem.paragraph }
  end

  trait :default do
    default true
  end
end

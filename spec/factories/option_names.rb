FactoryGirl.define do
  factory :option_name do
    account
    insales_id
    position 0
    title { Faker::Lorem.sentence }
  end
end

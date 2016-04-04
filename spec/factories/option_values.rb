FactoryGirl.define do
  factory :option_value do
    account
    insales_id
    option_name
    position 0
    title { Faker::Lorem.sentence }
  end
end

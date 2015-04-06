FactoryGirl.define do
  factory :client do
    insales_id
    name { Faker::Name.male_first_name }
    surname { Faker::Name.male_last_name }
    middlename { Faker::Name.male_middle_name }
    email { Faker::Internet.free_email }
    phone { Faker::PhoneNumber.cell_phone }
    registered false
    subscribe true
    bonus_points 0
    client_group_id 0

    trait :registered do
      registered true
    end
  end
end

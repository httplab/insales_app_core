FactoryGirl.define do
  factory :domain do
    insales_id
    account_id 1
    main false
    domain { Faker::Internet.domain_name }
  end
end

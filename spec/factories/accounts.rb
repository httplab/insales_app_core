FactoryGirl.define do
  factory :account do
    insales_id { rand(20000..30000) }
    insales_password { Faker::Internet.password(32) }
    insales_subdomain { "#{Faker::Internet.domain_word}/myinsales.ru" }
  end
end

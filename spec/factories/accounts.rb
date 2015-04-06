FactoryGirl.define do
  factory :account do
    insales_id
    insales_password { Faker::Internet.password(32) }
    insales_subdomain { "#{Faker::Lorem.word}/myinsales.ru" }
    last_install_date { rand(0..100).days.ago }
  end
end

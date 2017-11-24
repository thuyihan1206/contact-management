FactoryGirl.define do
  factory :contact do
    last_name   { Faker::Name.last_name }
    first_name  { Faker::Name.first_name }
    phone       { Faker::Base.numerify('(###)###-####') }
    email       { Faker::Internet.email }
  end
end

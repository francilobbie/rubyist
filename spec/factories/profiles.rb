FactoryBot.define do
  factory :profile do
    user { nil }
    first_name { "MyString" }
    last_name { "MyString" }
    bio { "MyText" }
    location { "MyString" }
  end
end

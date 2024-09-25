FactoryBot.define do
  factory :feedback do
    user { nil }
    content { "MyText" }
    category { "MyString" }
  end
end

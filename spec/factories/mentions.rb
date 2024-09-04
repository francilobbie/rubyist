FactoryBot.define do
  factory :mention do
    user { nil }
    mentionable { nil }
    content { "MyString" }
  end
end

FactoryBot.define do
  factory :donation do
    user { nil }
    amount { 1 }
    stripe_charge_id { "MyString" }
    currency { "MyString" }
    status { "MyString" }
  end
end

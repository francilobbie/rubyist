FactoryBot.define do
  factory :report do
    content { "MyText" }
    user { nil }
    reportable { nil }
  end
end

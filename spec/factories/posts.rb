FactoryBot.define do
  factory :post do
    title { "MyString" }
    body { "My post body" }
    tag_list { "first_tag, second_tag" }
  end
end

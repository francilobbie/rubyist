# Company.create([
#   { name: "Company One", address: "123 Example St, City", latitude: 48.8566, longitude: 2.3522 },
#   { name: "Company Two", address: "456 Example Ave, City", latitude: 37.7749, longitude: -122.4194 },
#   # Add more companies as needed
# ])
#   puts "#{Company.count} companies created"

require 'faker'

users = User.with_role(:writer).or(User.with_role(:admin))

100.times do
  Post.create!(
    title: Faker::Book.title,
    body: Faker::Lorem.paragraph(sentence_count: 5),
    published_at: Time.current,
    user: users.sample
  )
end

puts "#{Post.count} posts created"

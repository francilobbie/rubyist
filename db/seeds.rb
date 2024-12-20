# Company.create([
#   { name: "Company One", address: "123 Example St, City", latitude: 48.8566, longitude: 2.3522 },
#   { name: "Company Two", address: "456 Example Ave, City", latitude: 37.7749, longitude: -122.4194 },
#   # Add more companies as needed
# ])
#   puts "#{Company.count} companies created"

require 'faker'

users = User.with_role(:writer).or(User.with_role(:admin))

# Create admin and writer users if they don't exist
admin = User.find_or_create_by!(email: "franci@mail.com") do |user|
  user.password = "azerty"
  user.add_role(:admin)
end

writer = User.find_or_create_by!(email: "augustin@mail.com") do |user|
  user.password = "azerty"
  user.add_role(:writer)
end

puts "Admin and Writer users created."


100.times do
  Post.create!(
    title: Faker::Book.title,
    body: Faker::Lorem.paragraph(sentence_count: 5),
    published_at: Time.current,
    user: users.sample,
  )
end

puts "#{Post.count} posts created"

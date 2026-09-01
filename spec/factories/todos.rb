FactoryBot.define do
  factory :todo do
    title       { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    completed   { false }
    user
  end
end
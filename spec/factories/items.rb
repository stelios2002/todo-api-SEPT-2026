FactoryBot.define do
  factory :item do
    content   { Faker::Lorem.sentence(word_count: 4) }
    completed { false }
    todo
  end
end
FactoryBot.define do
  factory :item do
    content   { Faker::Lorem.sentence(word_count: 4) }
    completed { false }
    position  { 1 }
    todo
  end
end
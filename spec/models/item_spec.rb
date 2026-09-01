require "rails_helper"

RSpec.describe Item, type: :model do
  it { should belong_to(:todo) }
  it { should validate_presence_of(:content) }
  it { should validate_length_of(:content).is_at_most(500) }
end
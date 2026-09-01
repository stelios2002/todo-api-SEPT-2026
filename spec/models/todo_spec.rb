require "rails_helper"

RSpec.describe Todo, type: :model do
  it { should belong_to(:user) }
  it { should have_many(:items).dependent(:destroy) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(2).is_at_most(200) }

  describe "cascade delete" do
    it "διαγράφει και τα items του" do
      todo = create(:todo)
      create_list(:item, 3, todo: todo)

      expect { todo.destroy }.to change(Item, :count).by(-3)
    end
  end

  describe "defaults" do
    it "θέτει completed = false" do
      expect(Todo.new.completed).to eq(false)
    end
  end
end
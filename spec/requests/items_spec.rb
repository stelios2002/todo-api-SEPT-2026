require "rails_helper"

RSpec.describe "Items", type: :request do
  let(:user)    { create(:user) }
  let(:other)   { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:todo)    { create(:todo, user: user) }
  let!(:items)  { create_list(:item, 3, todo: todo) }
  let(:item_id) { items.first.id }

  describe "GET /todos/:todo_id/items" do
    it "επιστρέφει τα items" do
      get "/todos/#{todo.id}/items", headers: headers
      expect(response).to have_http_status(200)
      expect(json[:items].size).to eq(3)
    end

    it "επιστρέφει 401 χωρίς token, όχι 500" do
      get "/todos/#{todo.id}/items"
      expect(response).to have_http_status(401)
    end
  end

  describe "GET /todos/:todo_id/items/:id" do
    it "επιστρέφει ένα item" do
      get "/todos/#{todo.id}/items/#{item_id}", headers: headers
      expect(response).to have_http_status(200)
      expect(json[:id]).to eq(item_id)
    end

    it "404 όταν το item ανήκει σε άλλο todo" do
      foreign_item = create(:item, todo: create(:todo, user: user))
      get "/todos/#{todo.id}/items/#{foreign_item.id}", headers: headers
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /todos/:todo_id/items" do
    it "δημιουργεί item" do
      expect {
        post "/todos/#{todo.id}/items",
             params: { content: "Νέο item" }.to_json,
             headers: headers
      }.to change(Item, :count).by(1)

      expect(response).to have_http_status(201)
      expect(json[:content]).to eq("Νέο item")
    end

    it "απορρίπτει κενό content" do
      post "/todos/#{todo.id}/items",
           params: { content: "" }.to_json,
           headers: headers
      expect(response).to have_http_status(422)
    end

    it "404 σε todo άλλου χρήστη" do
      foreign_todo = create(:todo, user: other)
      post "/todos/#{foreign_todo.id}/items",
           params: { content: "Χ" }.to_json,
           headers: headers
      expect(response).to have_http_status(404)
    end
  end

  describe "PUT /todos/:todo_id/items/:id" do
    it "ενημερώνει το item" do
      put "/todos/#{todo.id}/items/#{item_id}",
          params: { content: "Αλλαγμένο", completed: true }.to_json,
          headers: headers

      expect(response).to have_http_status(200)
      expect(items.first.reload.content).to eq("Αλλαγμένο")
    end
  end

  describe "DELETE /todos/:todo_id/items/:id" do
    it "διαγράφει το item" do
      expect {
        delete "/todos/#{todo.id}/items/#{item_id}", headers: headers
      }.to change(Item, :count).by(-1)

      expect(response).to have_http_status(200)
    end
  end
end
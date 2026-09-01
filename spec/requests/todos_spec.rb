require "rails_helper"

RSpec.describe "Todos", type: :request do
  let(:user)    { create(:user) }
  let(:other)   { create(:user) }
  let(:headers) { auth_headers(user) }
  let!(:todos)  { create_list(:todo, 3, user: user) }
  let(:todo_id) { todos.first.id }

  describe "GET /todos" do
    it "επιστρέφει τα todos του χρήστη με τα items τους" do
      create_list(:item, 2, todo: todos.first)

      get "/todos", headers: headers
      
      expect(response).to have_http_status(:ok)

      expect(json[:meta][:total_count]).to eq(3)
      expect(json[:meta][:page]).to eq(1)
      expect(json[:meta][:per_page]).to eq(10)
      expect(json[:meta][:total_pages]).to eq(1)

      expect(json[:todos]).to be_an(Array)
      expect(json[:todos].size).to eq(3)
    end

    it "δεν δείχνει todos άλλου χρήστη" do
      create(:todo, user: other, title: "Κρυφό")

      get "/todos", headers: headers

      titles = json[:todos].map { |t| t[:title] }
      expect(titles).not_to include("Κρυφό")
    end

    it "επιστρέφει 401 χωρίς token" do
      get "/todos"
      expect(response).to have_http_status(401)
    end
  end

  describe "GET /todos/:id" do
    it "επιστρέφει το todo" do
      get "/todos/#{todo_id}", headers: headers
      expect(response).to have_http_status(200)
      expect(json[:id]).to eq(todo_id)
    end

    it "επιστρέφει 404 για ανύπαρκτο" do
      get "/todos/99999", headers: headers
      expect(response).to have_http_status(404)
      expect(json[:error]).to match(/not found/i)
    end

    it "επιστρέφει 404 για todo άλλου χρήστη" do
      foreign = create(:todo, user: other)
      get "/todos/#{foreign.id}", headers: headers
      expect(response).to have_http_status(404)
    end
  end

  describe "POST /todos" do
    it "δημιουργεί todo" do
      expect {
        post "/todos",
             params: { title: "Νέο todo", description: "Περιγραφή" }.to_json,
             headers: headers
      }.to change(Todo, :count).by(1)
      
      expect(response).to have_http_status(:created)
      expect(json[:message]).to eq("Todo created")

      expect(json[:todo][:title]).to eq("Νέο todo")
      expect(json[:todo][:description]).to eq("Περιγραφή")
      expect(json[:todo][:completed]).to eq(false)
      expect(json[:todo][:items_count]).to eq(0)
      expect(json[:todo][:id]).to be_present
    end

    it "απορρίπτει κενό title" do
      post "/todos", params: { title: "" }.to_json, headers: headers
      expect(response).to have_http_status(422)
    end
  end

  describe "PUT /todos/:id" do
    it "ενημερώνει το todo" do
      put "/todos/#{todo_id}",
          params: { title: "Ενημερωμένο", completed: true }.to_json,
          headers: headers

      expect(response).to have_http_status(200)
      expect(todos.first.reload.title).to eq("Ενημερωμένο")
      expect(todos.first.reload.completed).to be true
    end
  end

  describe "DELETE /todos/:id" do
    it "διαγράφει το todo και τα items του" do
      create_list(:item, 3, todo: todos.first)

      expect {
        delete "/todos/#{todo_id}", headers: headers
      }.to change(Todo, :count).by(-1).and change(Item, :count).by(-3)

      expect(response).to have_http_status(200)
      expect(json[:deleted_items]).to eq(3)
    end
  end
end
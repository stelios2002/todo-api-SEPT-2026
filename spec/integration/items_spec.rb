require "swagger_helper"

RSpec.describe "Items", type: :request do
  let(:user)          { create(:user) }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
  let(:todo)          { create(:todo, user: user) }
  let(:todo_id)       { todo.id }

  path "/todos/{todo_id}/items" do
    parameter name: :todo_id, in: :path, type: :integer, description: "ID του γονικού todo"

    get "Λίστα items ενός todo" do
      tags "Items"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "OK" do
        schema type: :object,
               properties: {
                 todo_id: { type: :integer },
                 count:   { type: :integer },
                 items:   { type: :array, items: { "$ref" => "#/components/schemas/Item" } }
               },
               required: %w[todo_id count items]

        let!(:list) { create_list(:item, 3, todo: todo) }
        run_test!
      end

      response "401", "Χωρίς token" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { nil }
        run_test!
      end

      response "404", "Το todo ανήκει σε άλλον χρήστη" do
        schema "$ref" => "#/components/schemas/Error"
        let(:todo_id) { create(:todo, user: create(:user)).id }
        run_test!
      end
    end

    post "Δημιουργία item" do
      tags "Items"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          content:   { type: :string, example: "Αγόρασε γάλα" },
          completed: { type: :boolean, example: false }
        },
        required: %w[content]
      }

      response "201", "Δημιουργήθηκε" do
        schema "$ref" => "#/components/schemas/Item"
        let(:payload) { { content: "Νέο item" } }
        run_test!
      end

      response "422", "Κενό content" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let(:payload) { { content: "" } }
        run_test!
      end
    end
  end

  path "/todos/{todo_id}/items/{id}" do
    parameter name: :todo_id, in: :path, type: :integer
    parameter name: :id,      in: :path, type: :integer

    get "Ανάκτηση item" do
      tags "Items"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "OK" do
        schema "$ref" => "#/components/schemas/Item"
        let(:id) { create(:item, todo: todo).id }
        run_test!
      end

      response "404", "Δεν βρέθηκε" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 99_999 }
        run_test!
      end
    end

    put "Ενημέρωση item" do
      tags "Items"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          content:   { type: :string },
          completed: { type: :boolean }
        }
      }

      response "200", "Ενημερώθηκε" do
        schema "$ref" => "#/components/schemas/Item"
        let(:id)      { create(:item, todo: todo).id }
        let(:payload) { { content: "Αλλαγμένο", completed: true } }
        run_test!
      end
    end

    delete "Διαγραφή item" do
      tags "Items"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "Διαγράφηκε" do
        let(:id) { create(:item, todo: todo).id }
        run_test!
      end
    end
  end
end
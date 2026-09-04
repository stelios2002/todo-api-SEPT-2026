require "swagger_helper"

RSpec.describe "Todos", type: :request do
  let(:user)          { create(:user) }
  let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }

  path "/todos" do
    get "Λίστα todos του συνδεδεμένου χρήστη" do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "OK" do
        schema type: :object,
               properties: {
                 todos:       { type: :array, items: { "$ref" => "#/components/schemas/Todo" } },
                 total_count: { type: :integer }
               }

        let!(:todos) { create_list(:todo, 3, user: user) }
        run_test!
      end

      response "401", "Λείπει ή είναι άκυρο το token" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { nil }
        run_test!
      end
    end

    post "Δημιουργία todo" do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title:       { type: :string, example: "Ψώνια" },
          description: { type: :string, example: "Για το Σαββατοκύριακο" }
        },
        required: %w[title]
      }

      response "201", "Δημιουργήθηκε" do
        schema "$ref" => "#/components/schemas/Todo"
        let(:payload) { { title: "Νέο todo", description: "Περιγραφή" } }
        run_test!
      end

      response "422", "Μη έγκυρο title" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let(:payload) { { title: "" } }
        run_test!
      end
    end
  end

  path "/todos/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID του todo"

    get "Ανάκτηση ενός todo" do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "OK" do
        schema "$ref" => "#/components/schemas/Todo"
        let(:id) { create(:todo, user: user).id }
        run_test!
      end

      response "404", "Δεν βρέθηκε" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 99_999 }
        run_test!
      end
    end

    put "Ενημέρωση todo" do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title:       { type: :string },
          description: { type: :string },
          completed:   { type: :boolean }
        }
      }

      response "200", "Ενημερώθηκε" do
        schema "$ref" => "#/components/schemas/Todo"
        let(:id)      { create(:todo, user: user).id }
        let(:payload) { { title: "Ενημερωμένο", completed: true } }
        run_test!
      end
    end

    delete "Διαγραφή todo και των items του" do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]

      response "200", "Διαγράφηκε" do
        schema type: :object,
               properties: {
                 message:       { type: :string },
                 deleted_items: { type: :integer }
               }

        let(:id) { create(:todo, user: user).id }
        run_test!
      end
    end
  end
end
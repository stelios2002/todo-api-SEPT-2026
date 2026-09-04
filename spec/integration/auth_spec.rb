require "swagger_helper"

RSpec.describe "Authentication", type: :request do
  path "/signup" do
    post "Εγγραφή νέου χρήστη" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name:     { type: :string, example: "Γιώργος Παπαδόπουλος" },
          email:    { type: :string, example: "giorgos@example.com" },
          password: { type: :string, example: "password123" }
        },
        required: %w[name email password]
      }

      response "201", "Ο χρήστης δημιουργήθηκε" do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 token:   { type: :string }
               }

        let(:payload) { { name: "Test", email: "new@example.com", password: "password123" } }
        run_test!
      end

      response "422", "Μη έγκυρα δεδομένα" do
        schema "$ref" => "#/components/schemas/ValidationError"

        let(:payload) { { name: "", email: "bad", password: "1" } }
        run_test!
      end
    end
  end

  path "/auth/login" do
    post "Σύνδεση χρήστη" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          email:    { type: :string, example: "giorgos@example.com" },
          password: { type: :string, example: "password123" }
        },
        required: %w[email password]
      }

      response "200", "Επιτυχής σύνδεση" do
        schema type: :object,
               properties: { token: { type: :string } }

        let!(:user)   { create(:user, email: "login@example.com", password: "password123") }
        let(:payload) { { email: "login@example.com", password: "password123" } }
        run_test!
      end

      response "401", "Λάθος στοιχεία" do
        schema "$ref" => "#/components/schemas/Error"

        let!(:user)   { create(:user, email: "login@example.com", password: "password123") }
        let(:payload) { { email: "login@example.com", password: "wrong" } }
        run_test!
      end
    end
  end
end
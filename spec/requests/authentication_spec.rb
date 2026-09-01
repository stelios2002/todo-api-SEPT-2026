require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "POST /signup" do
    it "δημιουργεί χρήστη και επιστρέφει token" do
      post "/signup",
           params: { name: "Test", email: "t@example.com", password: "password123" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(201)
      expect(json[:token]).to be_present
    end

    it "απορρίπτει διπλό email" do
      create(:user, email: "dup@example.com")

      post "/signup",
           params: { name: "X", email: "dup@example.com", password: "password123" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(422)
    end
  end

  describe "POST /auth/login" do
    let!(:user) { create(:user, password: "password123") }

    it "επιστρέφει token με σωστά στοιχεία" do
      post "/auth/login",
           params: { email: user.email, password: "password123" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(200)
      expect(json[:token]).to be_present
    end

    it "απορρίπτει λάθος password" do
      post "/auth/login",
           params: { email: user.email, password: "wrong" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(401)
    end
  end

  describe "GET /auth/logout" do
    it "απαντά 200" do
      get "/auth/logout", headers: json_headers
      expect(response).to have_http_status(200)
    end
  end
end